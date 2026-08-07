import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puldapii/config/bloc/account_bloc/account_bloc.dart';
import 'package:puldapii/config/bloc/profile_bloc/profile_bloc.dart';
import 'package:puldapii/pages/account/pages/account_profile_page.dart';
import 'package:puldapii/pages/account/pages/consult_history_page.dart';
import 'package:puldapii/utils/services/profile_service.dart';

class AccountLoggedInView extends StatefulWidget {
  final VoidCallback onLogoutSuccess;

  const AccountLoggedInView({super.key, required this.onLogoutSuccess});

  @override
  State<AccountLoggedInView> createState() => _AccountLoggedInViewState();
}

class _AccountLoggedInViewState extends State<AccountLoggedInView> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<AccountBloc>().add(AccountStarted());
    });
  }

  String? _getProfilePhotoUrl(Map<String, dynamic> user) {
    // Untuk akun ustadz: response-nya biasanya nested
    final ustadz = user['ustadz'] is Map<String, dynamic>
        ? user['ustadz'] as Map<String, dynamic>
        : user['ustadz'] is Map
        ? Map<String, dynamic>.from(user['ustadz'])
        : null;

    final ustadzImageUrl = ustadz?['image_url']?.toString();
    final ustadzImagePath = ustadz?['image']?.toString();

    if (ustadzImageUrl != null && ustadzImageUrl.trim().isNotEmpty) {
      return ustadzImageUrl;
    }

    if (ustadzImagePath != null && ustadzImagePath.trim().isNotEmpty) {
      return 'https://layanan.puldapii.or.id/files/${ustadzImagePath.trim()}';
    }

    // Untuk akun user biasa
    final profilePhotoUrl = user['profile_photo_url']?.toString();
    final profilePhotoPath = user['profile_photo']?.toString();

    if (profilePhotoUrl != null && profilePhotoUrl.trim().isNotEmpty) {
      return profilePhotoUrl;
    }

    if (profilePhotoPath != null && profilePhotoPath.trim().isNotEmpty) {
      return 'https://layanan.puldapii.or.id/files/${profilePhotoPath.trim()}';
    }

    return null;
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromRGBO(90, 178, 173, 1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(
                      90,
                      178,
                      173,
                      1,
                    ).withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromRGBO(
                        90,
                        178,
                        173,
                        1,
                      ).withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 34,
                    color: Color(0xFFE53935),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Keluar Akun?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Apakah kamu yakin ingin keluar dari akun ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color.fromRGBO(
                              90,
                              178,
                              173,
                              1,
                            ),
                            side: const BorderSide(
                              color: Color.fromRGBO(90, 178, 173, 1),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Keluar",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true && context.mounted) {
      context.read<AccountBloc>().add(AccountLoggedOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state is AccountLogoutSuccess) {
          widget.onLogoutSuccess();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Berhasil keluar akun",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AccountLoading || state is AccountInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        if (state is AccountFailure) {
          return _ErrorView(
            onRetry: () {
              context.read<AccountBloc>().add(AccountStarted());
            },
            onLogout: () {
              context.read<AccountBloc>().add(AccountLoggedOut());
            },
          );
        }

        if (state is AccountLoaded) {
          final user = state.user;

          final accountUser = user['user'] is Map
              ? Map<String, dynamic>.from(user['user'])
              : user;

          final name = accountUser['name']?.toString() ?? 'Pengguna';
          final email = accountUser['email']?.toString() ?? '-';
          final rawPhotoUrl = _getProfilePhotoUrl(user);

          final ustadz = user['ustadz'] is Map
              ? Map<String, dynamic>.from(user['ustadz'])
              : null;

          final cacheKey =
              ustadz?['updated_at']?.toString() ??
              user['updated_at']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString();

          final photoUrl = rawPhotoUrl == null
              ? null
              : '$rawPhotoUrl?v=$cacheKey';

          debugPrint('ACCOUNT USER AFTER REFRESH: $user');
          debugPrint('ACCOUNT PHOTO URL AFTER REFRESH: $photoUrl');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                _ProfileCard(
                  key: ValueKey(photoUrl),
                  name: name,
                  email: email,
                  profilePhotoUrl: photoUrl,
                ),

                const SizedBox(height: 20),

                _MenuSection(
                  children: [
                    _MenuTile(
                      icon: Icons.person_outline_rounded,
                      title: "Profil Saya",
                      subtitle: "Lihat dan ubah informasi akun",
                      onTap: () => _openProfilePage(context),
                    ),
                    _MenuTile(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Konsultasi',
                      subtitle: "Lihat konsultasi terakhir di aplikasi",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConsultHistoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Keluar Akun",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        );
      },
    );
  }

  Future<void> _openProfilePage(BuildContext context) async {
    final accountBloc = context.read<AccountBloc>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountBloc),
            BlocProvider(
              create: (_) => ProfileBloc(
                profileService: ProfileService(),
                imagePicker: ImagePicker(),
              ),
            ),
          ],
          child: const UpdateProfilePage(),
        ),
      ),
    );

    if (!mounted) return;

    context.read<AccountBloc>().add(AccountStarted());
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? profilePhotoUrl;

  const _ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto =
        profilePhotoUrl != null && profilePhotoUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.teal.withOpacity(0.25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasPhoto
                  ? Image.network(
                      profilePhotoUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.teal,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.teal,
                    ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assalamu’alaikum,",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;

  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index != children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                  indent: 68,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.teal, size: 22),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const _ErrorView({required this.onRetry, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              const Text(
                "Gagal memuat akun",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                "Sesi mungkin sudah berakhir. Coba muat ulang atau keluar akun.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLogout,
                      child: const Text("Keluar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Coba Lagi"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
