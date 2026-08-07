import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  static Future<void> openWhatsApp({
    required BuildContext context,
    required String phoneNumber,
    String message = 'Assalamu\'alaikum, saya ingin menghubungi admin.',
  }) async {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    final Uri waUri = Uri.parse(
      'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}',
    );

    final bool opened = await launchUrl(
      waUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak bisa dibuka')),
      );
    }
  }

  static Future<void> sendEmail({
    required BuildContext context,
    required String? email,
    String subject = 'Permintaan Informasi',
    String body = 'Assalamu\'alaikum,\n\nSaya ingin menghubungi Anda.\n',
  }) async {
    final targetEmail = (email ?? '').trim();

    if (targetEmail.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email tidak tersedia')));
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: targetEmail,
      query: _encodeQueryParameters({'subject': subject, 'body': body}),
    );

    final bool opened = await launchUrl(emailUri);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aplikasi email tidak bisa dibuka')),
      );
    }
  }
}
