import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaawunBankAccountDialog extends StatelessWidget {
  const TaawunBankAccountDialog({
    super.key,
    required this.bankAccount,
    required this.amount,
    this.primary = const Color(0xFF009E96),
    this.onUnderstand,
  });

  final Map<String, dynamic>? bankAccount;
  final int amount;
  final Color primary;
  final VoidCallback? onUnderstand;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic>? bankAccount,
    required int amount,
    Color primary = const Color(0xFF009E96),
    VoidCallback? onUnderstand,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return TaawunBankAccountDialog(
          bankAccount: bankAccount,
          amount: amount,
          primary: primary,
          onUnderstand: onUnderstand,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankName = bankAccount?['bank_name']?.toString() ?? '-';
    final accountNumber = bankAccount?['account_number']?.toString() ?? '-';
    final accountName = bankAccount?['account_name']?.toString() ?? '-';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F7F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: primary,
                size: 34,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Taawun Berhasil Dicatat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF006B67),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Silakan transfer nominal bantuan ke rekening tujuan berikut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE4F7F5), width: 1.4),
              ),
              child: Column(
                children: [
                  _TransferInfoRow(
                    label: 'Nominal',
                    value: _formatRupiah(amount),
                    valueColor: primary,
                  ),
                  const SizedBox(height: 12),
                  _TransferInfoRow(label: 'Bank', value: bankName),
                  const SizedBox(height: 12),
                  _TransferInfoRow(
                    label: 'No. Rekening',
                    value: accountNumber,
                    primary: primary,
                    onCopy: accountNumber == '-'
                        ? null
                        : () => _copyToClipboard(context, accountNumber),
                  ),
                  const SizedBox(height: 12),
                  _TransferInfoRow(label: 'Atas Nama', value: accountName),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F7F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Setelah transfer, simpan bukti pembayaran untuk proses verifikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFF245B58),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onUnderstand?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Saya Mengerti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nomor rekening berhasil disalin.'),
        backgroundColor: primary,
      ),
    );
  }
}

class _TransferInfoRow extends StatelessWidget {
  const _TransferInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.primary = const Color(0xFF009E96),
    this.onCopy,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Color primary;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.5,
              color: valueColor ?? const Color(0xFF333333),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        if (onCopy != null) ...[
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFFE4F7F5),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 34,
                height: 34,
                child: Icon(Icons.copy_rounded, size: 18, color: primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _formatRupiah(int value) {
  return 'Rp${_formatNumber(value)}';
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final position = text.length - i;

    buffer.write(text[i]);

    if (position > 1 && position % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}
