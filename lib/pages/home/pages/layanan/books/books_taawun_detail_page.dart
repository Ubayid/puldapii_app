import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puldapii/config/bloc/book_taawun_bloc/book_taawun_bloc.dart';
import 'package:puldapii/models/book_taawun_model.dart';
import 'package:puldapii/utils/services/home/book_taawun_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class BookTaawunDetailPage extends StatefulWidget {
  const BookTaawunDetailPage({super.key, required this.item});

  final BookTaawunModel item;

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color accentColor = Color(0xFF12A99C);

  @override
  State<BookTaawunDetailPage> createState() => _BookTaawunDetailPageState();
}

class _BookTaawunDetailPageState extends State<BookTaawunDetailPage> {
  late final Future<_BankAccountInfo?> _bankAccountFuture;

  final ImagePicker _picker = ImagePicker();

  bool _isUploadingProof = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();

    _bankAccountFuture = _loadBankAccount();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookTaawunBloc>().add(
        BookTaawunDetailLoaded(widget.item.id),
      );
    });
  }

  Future<_BankAccountInfo?> _loadBankAccount() async {
    try {
      final response = await BookTaawunService().getBankAccount();
      return _BankAccountInfo.fromResponse(response);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickAndUploadProof(BookTaawunModel item) async {
    if (_isUploadingProof) return;

    if (!_canCancelTaawunStatus(item.status)) {
      _showOverlayMessage(context, 'Taawun sudah tidak bisa diubah.');
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingProof = true;
      });

      await BookTaawunService().updateTaawun(
        id: item.id,
        bookId: item.bookId,
        donorName: item.donorName,
        donorWhatsapp: item.donorWhatsapp,
        donorEmail: item.donorEmail.trim().isEmpty ? null : item.donorEmail,
        amount: item.amount,
        paymentProof: pickedFile,
      );

      if (!mounted) return;

      _showOverlayMessage(context, 'Bukti transfer berhasil diunggah');

      context.read<BookTaawunBloc>().add(BookTaawunDetailLoaded(item.id));
    } catch (e) {
      if (!mounted) return;

      _showOverlayMessage(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isUploadingProof = false;
      });
    }
  }

  Future<void> _cancelTaawun(BookTaawunModel item) async {
    if (_isCancelling) return;

    if (!_canCancelTaawunStatus(item.status)) {
      _showOverlayMessage(context, 'Taawun ini sudah tidak bisa dibatalkan.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Batalkan Taawun?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Taawun yang belum disetujui admin dapat dibatalkan. Status akan diubah menjadi dibatalkan, bukan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      setState(() {
        _isCancelling = true;
      });

      await BookTaawunService().cancelTaawun(item.id);

      if (!mounted) return;

      _showOverlayMessage(context, 'Taawun berhasil dibatalkan');

      context.read<BookTaawunBloc>().add(BookTaawunDetailLoaded(item.id));
    } catch (e) {
      if (!mounted) return;

      _showOverlayMessage(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isCancelling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SecondaryHeader(title: 'Detail Taawun'),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<BookTaawunBloc, BookTaawunState>(
                builder: (context, state) {
                  final item = state.selectedTaawun?.id == widget.item.id
                      ? state.selectedTaawun!
                      : widget.item;

                  if (state.isDetailLoading && state.selectedTaawun == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: BookTaawunDetailPage.accentColor,
                      ),
                    );
                  }

                  return _DetailContent(
                    item: item,
                    bankAccountFuture: _bankAccountFuture,
                    isUploadingProof: _isUploadingProof,
                    isCancelling: _isCancelling,
                    onUploadProof: () => _pickAndUploadProof(item),
                    onCancelTaawun: () => _cancelTaawun(item),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.item,
    required this.bankAccountFuture,
    required this.isUploadingProof,
    required this.isCancelling,
    required this.onUploadProof,
    required this.onCancelTaawun,
  });

  final BookTaawunModel item;
  final Future<_BankAccountInfo?> bankAccountFuture;
  final bool isUploadingProof;
  final bool isCancelling;
  final VoidCallback onUploadProof;
  final VoidCallback onCancelTaawun;

  @override
  Widget build(BuildContext context) {
    final bookTitle = item.book?.title.trim().isNotEmpty == true
        ? item.book!.title
        : 'Buku Taawun';

    final coverUrl = item.book?.coverImageUrl.trim() ?? '';

    final donorName = item.isAnonymous
        ? 'Hamba Allah'
        : _safeText(item.donorName);

    final createdDate = formatDate(item.createdAt);
    final proofUrl = item.paymentProofUrl.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          _HeaderCard(
            title: bookTitle,
            coverUrl: coverUrl,
            donorName: donorName,
            date: createdDate,
            status: item.status,
            amount: item.amount,
          ),

          const SizedBox(height: 14),

          FutureBuilder<_BankAccountInfo?>(
            future: bankAccountFuture,
            builder: (context, snapshot) {
              final bank = snapshot.data;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _SectionCard(
                  title: 'Rekening Tujuan',
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Memuat data rekening...',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6D7476),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (bank == null || !bank.hasData) {
                return const _BankAccountEmptyCard();
              }

              return _BankAccountCard(
                bank: bank,
                amount: item.amount,
                invoiceNumber: item.invoiceNumber,
              );
            },
          ),

          const SizedBox(height: 14),

          _SectionCard(
            title: 'Data Donatur',
            children: [
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Nama Donatur',
                value: donorName,
              ),
              _InfoRow(
                icon: Icons.call_outlined,
                label: 'Nomor WhatsApp',
                value: item.isAnonymous ? '-' : _safeText(item.donorWhatsapp),
              ),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: item.isAnonymous ? '-' : _safeText(item.donorEmail),
              ),
              _InfoRow(
                icon: Icons.visibility_off_outlined,
                label: 'Anonim',
                value: item.isAnonymous ? 'Ya' : 'Tidak',
              ),
            ],
          ),

          const SizedBox(height: 14),

          _SectionCard(
            title: 'Status Pembayaran',
            children: [
              _InfoRow(
                icon: Icons.verified_user_outlined,
                label: 'Status',
                value: _statusLabel(item.status),
              ),
              _InfoRow(
                icon: Icons.upload_file_outlined,
                label: 'Bukti Transfer',
                value: proofUrl.isNotEmpty
                    ? 'Sudah diunggah'
                    : 'Belum diunggah',
              ),
              if (item.paymentProofUploadedAt != null)
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Tanggal Upload Bukti',
                  value: formatDate(item.paymentProofUploadedAt),
                ),
              if (item.verifiedAt != null)
                _InfoRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Tanggal Verifikasi',
                  value: formatDate(item.verifiedAt),
                ),
              if (item.verifier != null)
                _InfoRow(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Diverifikasi Oleh',
                  value: _safeText(item.verifier!.name),
                ),
            ],
          ),

          const SizedBox(height: 14),

          _PaymentProofUploadCard(
            imageUrl: proofUrl,
            isUploading: isUploadingProof,
            enabled: _canCancelTaawunStatus(item.status),
            onUploadTap: onUploadProof,
          ),

          if (_canCancelTaawunStatus(item.status)) ...[
            const SizedBox(height: 14),
            _CancelTaawunCard(
              isCancelling: isCancelling,
              onCancelTap: onCancelTaawun,
            ),
          ],

          if (item.adminNote.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _TextSectionCard(title: 'Catatan Admin', text: item.adminNote),
          ],
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.coverUrl,
    required this.donorName,
    required this.date,
    required this.status,
    required this.amount,
  });

  final String title;
  final String coverUrl;
  final String donorName;
  final String date;
  final String status;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookCover(title: title, coverUrl: coverUrl),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusChip(status: status),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: BookTaawunDetailPage.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: BookTaawunDetailPage.accentColor,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          donorName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.25,
                            color: BookTaawunDetailPage.accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 15,
                        color: Color(0xFF6D7476),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3E4D4F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.title, required this.coverUrl});

  final String title;
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 122,
      decoration: BoxDecoration(
        color: const Color(0xFF2F7468),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _DefaultBookCover(title: title);
              },
            )
          : _DefaultBookCover(title: title),
    );
  }
}

class _DefaultBookCover extends StatelessWidget {
  const _DefaultBookCover({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 7,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.16),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(9),
              ),
            ),
          ),
        ),
        Positioned(
          right: -14,
          bottom: -8,
          child: Icon(
            Icons.volunteer_activism_outlined,
            size: 74,
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.08,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({
    required this.bank,
    required this.amount,
    required this.invoiceNumber,
  });

  final _BankAccountInfo bank;
  final int amount;
  final String invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF186450), Color(0xFF12A99C)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _safeText(bank.bankName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nomor Rekening',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _safeText(bank.accountNumber),
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 1.1,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CopyButton(
                        value: bank.accountNumber,
                        message: 'Nomor rekening disalin',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Atas Nama',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _safeText(bank.accountName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _TransferInfoBox(
              icon: Icons.payments_outlined,
              label: 'Nominal Transfer',
              value: formatRupiah(amount),
              copyValue: amount.toString(),
              copyMessage: 'Nominal transfer disalin',
            ),
            const SizedBox(height: 8),
            _TransferInfoBox(
              icon: Icons.receipt_long_outlined,
              label: 'Invoice',
              value: _safeText(invoiceNumber),
              copyValue: invoiceNumber,
              copyMessage: 'Invoice disalin',
            ),
          ],
        ),
      ),
    );
  }
}

class _BankAccountEmptyCard extends StatelessWidget {
  const _BankAccountEmptyCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Rekening Tujuan',
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Data rekening belum tersedia.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6D7476),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransferInfoBox extends StatelessWidget {
  const _TransferInfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.copyValue,
    required this.copyMessage,
  });

  final IconData icon;
  final String label;
  final String value;
  final String copyValue;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
      decoration: BoxDecoration(
        color: BookTaawunDetailPage.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: BookTaawunDetailPage.accentColor.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: BookTaawunDetailPage.accentColor),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A8385),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF263638),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _CopyButton(value: copyValue, message: copyMessage, isDark: false),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({
    required this.value,
    required this.message,
    this.isDark = true,
  });

  final String value;
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: cleanValue.isEmpty
          ? null
          : () async {
              await Clipboard.setData(ClipboardData(text: cleanValue));

              if (!context.mounted) return;

              _showOverlayMessage(context, message);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.16) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.22)
                : BookTaawunDetailPage.accentColor.withOpacity(0.20),
          ),
        ),
        child: Icon(
          Icons.copy_rounded,
          size: 15,
          color: isDark ? Colors.white : BookTaawunDetailPage.accentColor,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: BookTaawunDetailPage.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BookTaawunDetailPage.accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: BookTaawunDetailPage.accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7A8385),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Color(0xFF263638),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSectionCard extends StatelessWidget {
  const _TextSectionCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: BookTaawunDetailPage.accentColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notes_outlined,
                size: 17,
                color: BookTaawunDetailPage.accentColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF3E4D4F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PaymentProofUploadCard extends StatelessWidget {
  const _PaymentProofUploadCard({
    required this.imageUrl,
    required this.isUploading,
    required this.enabled,
    required this.onUploadTap,
  });

  final String imageUrl;
  final bool isUploading;
  final bool enabled;
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bukti Transfer',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: BookTaawunDetailPage.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const _ProofPlaceholder(
                      text: 'Bukti transfer tidak dapat dimuat',
                    );
                  },
                ),
              )
            else
              const _ProofPlaceholder(text: 'Belum ada bukti transfer'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: !enabled || isUploading ? null : onUploadTap,
                icon: isUploading
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded, size: 20),
                label: Text(
                  isUploading
                      ? 'Mengunggah...'
                      : hasImage
                      ? 'Ganti Bukti Transfer'
                      : 'Unggah Bukti Transfer',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BookTaawunDetailPage.accentColor,
                  disabledBackgroundColor: BookTaawunDetailPage.accentColor
                      .withOpacity(0.55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih gambar bukti transfer dari galeri. Setelah berhasil, data detail akan dimuat ulang otomatis.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: Color(0xFF6D7476),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelTaawunCard extends StatelessWidget {
  const _CancelTaawunCard({
    required this.isCancelling,
    required this.onCancelTap,
  });

  final bool isCancelling;
  final VoidCallback onCancelTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : onCancelTap,
                icon: isCancelling
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.redAccent,
                        ),
                      )
                    : const Icon(Icons.block_rounded, size: 20),
                label: Text(
                  isCancelling ? 'Membatalkan...' : 'Batalkan Taawun',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofPlaceholder extends StatelessWidget {
  const _ProofPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 34, color: Color(0xFF6D7476)),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6D7476),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final String label;
    final Color color;
    final IconData icon;

    if (normalized == 'approved' ||
        normalized == 'disetujui' ||
        normalized == 'diterima') {
      label = 'Disetujui';
      color = BookTaawunDetailPage.accentColor;
      icon = Icons.check_circle_rounded;
    } else if (normalized == 'rejected' || normalized == 'ditolak') {
      label = 'Ditolak';
      color = Colors.redAccent;
      icon = Icons.cancel_rounded;
    } else if (normalized == 'cancelled' || normalized == 'dibatalkan') {
      label = 'Dibatalkan';
      color = Colors.redAccent;
      icon = Icons.block_rounded;
    } else if (normalized == 'process' ||
        normalized == 'processing' ||
        normalized == 'diproses') {
      label = 'Diproses';
      color = Colors.orange;
      icon = Icons.timelapse_rounded;
    } else {
      label = 'Menunggu';
      color = Colors.blueGrey;
      icon = Icons.hourglass_bottom_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountInfo {
  const _BankAccountInfo({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  final String bankName;
  final String accountNumber;
  final String accountName;

  bool get hasData {
    return bankName.trim().isNotEmpty ||
        accountNumber.trim().isNotEmpty ||
        accountName.trim().isNotEmpty;
  }

  factory _BankAccountInfo.fromResponse(Map<String, dynamic> response) {
    dynamic source = response['data'];

    if (source is Map && source['bank_account'] is Map) {
      source = source['bank_account'];
    }

    if (source is! Map && response['bank_account'] is Map) {
      source = response['bank_account'];
    }

    if (source is! Map) {
      source = response;
    }

    final map = Map<String, dynamic>.from(source);

    return _BankAccountInfo(
      bankName: _readAny(map, ['bank_name', 'bankName', 'bank']),
      accountNumber: _readAny(map, [
        'account_number',
        'accountNumber',
        'rekening',
        'number',
      ]),
      accountName: _readAny(map, [
        'account_name',
        'accountName',
        'atas_nama',
        'name',
      ]),
    );
  }
}

String _readAny(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key]?.toString().trim() ?? '';

    if (value.isNotEmpty) {
      return value;
    }
  }

  return '';
}

String _safeText(String? value) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) return '-';

  return text;
}

String _statusLabel(String status) {
  final normalized = status.toLowerCase();

  if (normalized == 'approved' ||
      normalized == 'disetujui' ||
      normalized == 'diterima') {
    return 'Disetujui';
  }

  if (normalized == 'rejected' || normalized == 'ditolak') {
    return 'Ditolak';
  }

  if (normalized == 'cancelled' || normalized == 'dibatalkan') {
    return 'Dibatalkan';
  }

  if (normalized == 'process' ||
      normalized == 'processing' ||
      normalized == 'diproses') {
    return 'Diproses';
  }

  return 'Menunggu';
}

bool _canCancelTaawunStatus(String status) {
  final normalized = status.toLowerCase().trim();

  return normalized == 'pending' ||
      normalized == 'menunggu' ||
      normalized == 'process' ||
      normalized == 'processing' ||
      normalized == 'diproses';
}

String formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}

String formatRupiah(int value) {
  return 'Rp ${formatNumber(value)}';
}

String formatDate(DateTime? value) {
  if (value == null) return 'Tanggal tidak tersedia';

  final local = value.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();

  return '$day/$month/$year';
}

void _showOverlayMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 20,
        right: 20,
        bottom: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
