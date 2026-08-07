import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NoInternetExitGuard extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const NoInternetExitGuard({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<NoInternetExitGuard> createState() => _NoInternetExitGuardState();
}

class _NoInternetExitGuardState extends State<NoInternetExitGuard> {
  StreamSubscription<InternetStatus>? _internetSubscription;

  bool _isDialogShowing = false;
  bool _alreadyExit = false;

  BuildContext? _dialogContext;

  static const Color primaryColor = Colors.teal;
  static const Color softYellow = Color.fromRGBO(255, 247, 222, 1);
  static const Color darkText = Color.fromRGBO(35, 35, 35, 1);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialConnection();
    });

    _internetSubscription = InternetConnection().onStatusChange.listen((
      status,
    ) {
      debugPrint('INTERNET STATUS: $status');

      if (status == InternetStatus.disconnected) {
        _showNoInternetDialog();
      } else if (status == InternetStatus.connected) {
        _closeDialogWhenConnected();
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;

      debugPrint('HAS INTERNET: $hasInternet');

      if (!hasInternet) {
        _showNoInternetDialog();
      }
    } catch (e) {
      debugPrint('CHECK INTERNET ERROR: $e');
      _showNoInternetDialog();
    }
  }

  void _closeDialogWhenConnected() {
    final dialogContext = _dialogContext;

    if (!_isDialogShowing || dialogContext == null) {
      return;
    }

    if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
      Navigator.of(dialogContext, rootNavigator: true).pop();
    }

    _dialogContext = null;
    _isDialogShowing = false;
  }

  void _showNoInternetDialog() {
    if (_alreadyExit || _isDialogShowing) {
      return;
    }

    final context = widget.navigatorKey.currentContext;

    if (context == null) {
      debugPrint('Navigator context masih null');

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showNoInternetDialog();
        }
      });

      return;
    }

    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        _dialogContext = dialogContext;

        bool isChecking = false;
        String? connectionMessage;

        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> refreshInternet() async {
                if (isChecking) {
                  return;
                }

                setDialogState(() {
                  isChecking = true;
                  connectionMessage = null;
                });

                try {
                  // Sedikit jeda agar koneksi Wi-Fi/data seluler sempat aktif.
                  await Future.delayed(const Duration(milliseconds: 500));

                  final hasInternet =
                      await InternetConnection().hasInternetAccess;

                  if (!context.mounted) {
                    return;
                  }

                  if (hasInternet) {
                    Navigator.of(context, rootNavigator: true).pop();

                    final navigatorContext = widget.navigatorKey.currentContext;

                    if (navigatorContext != null && navigatorContext.mounted) {
                      ScaffoldMessenger.of(navigatorContext).showSnackBar(
                        const SnackBar(
                          content: Text('Koneksi internet berhasil terhubung.'),
                          backgroundColor: Colors.teal,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    return;
                  }

                  setDialogState(() {
                    isChecking = false;
                    connectionMessage =
                        'Internet masih belum terhubung. '
                        'Periksa Wi-Fi atau data seluler Anda.';
                  });
                } catch (e) {
                  debugPrint('REFRESH INTERNET ERROR: $e');

                  if (!context.mounted) {
                    return;
                  }

                  setDialogState(() {
                    isChecking = false;
                    connectionMessage =
                        'Gagal memeriksa koneksi. Silakan coba kembali.';
                  });
                }
              }

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: softYellow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.45),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: primaryColor,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Koneksi Tidak Terdeteksi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkText,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Anda sedang tidak terhubung ke internet. '
                        'Silakan aktifkan Wi-Fi atau data seluler, '
                        'kemudian tekan tombol Coba Lagi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      if (connectionMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          connectionMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isChecking ? null : refreshInternet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: primaryColor.withOpacity(
                              0.6,
                            ),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: isChecking
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.3,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 22),
                          label: Text(
                            isChecking ? 'Memeriksa...' : 'Coba Lagi',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: TextButton(
                          onPressed: isChecking
                              ? null
                              : () {
                                  _alreadyExit = true;

                                  Navigator.of(
                                    dialogContext,
                                    rootNavigator: true,
                                  ).pop();

                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    SystemNavigator.pop,
                                  );
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: const Text(
                            'Keluar dari Aplikasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      _dialogContext = null;
      _isDialogShowing = false;
    });
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    _dialogContext = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
