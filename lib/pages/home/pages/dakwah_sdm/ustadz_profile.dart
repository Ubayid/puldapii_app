import 'package:flutter/material.dart';
import 'package:puldapii/models/ustadz_model.dart';
import 'package:puldapii/utils/helper/contact_launcher.dart';
import 'package:puldapii/utils/services/app_setting_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/card_youtube_video.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/helper/ustadz_icon_mapper.dart';

const kPrimaryTeal = Color.fromRGBO(90, 178, 173, 1);

/// =======================
/// LIST PAGE
/// =======================
class UstadzListPage extends StatelessWidget {
  final List<UstadzModel> items;

  const UstadzListPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('Belum ada data.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ustadz = items[index];

                return UstadzCard(
                  ustadz: ustadz,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UstadzDetailPage(ustadz: ustadz),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// =======================
/// CARD ITEM
/// =======================
class UstadzCard extends StatelessWidget {
  final UstadzModel ustadz;
  final VoidCallback? onTap;

  const UstadzCard({super.key, required this.ustadz, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UstadzAvatar(imageUrl: ustadz.imageUrl),
              const SizedBox(height: 10),

              Text(
                ustadz.name ?? '-',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (_hasText(ustadz.title)) ...[
                const SizedBox(height: 4),
                Text(
                  ustadz.title!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],

              const SizedBox(height: 10),
              _StatusPill(status: ustadz.status),

              if (ustadz.expertiseNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: ustadz.expertiseNames
                      .map((e) => _MiniChip(text: e))
                      .toList(),
                ),
              ],

              if (_hasText(ustadz.mainTheme) || _hasText(ustadz.city)) ...[
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_hasText(ustadz.mainTheme))
                      _MiniChip(text: ustadz.mainTheme!),
                    if (_hasText(ustadz.city)) _MiniChip(text: ustadz.city!),
                  ],
                ),
              ],

              if (_hasText(ustadz.code)) ...[
                const SizedBox(height: 8),
                Text(ustadz.code!, style: theme.textTheme.labelMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================
/// DETAIL PAGE
/// =======================
class UstadzDetailPage extends StatelessWidget {
  final UstadzModel ustadz;

  const UstadzDetailPage({super.key, required this.ustadz});

  @override
  Widget build(BuildContext context) {
    final roles = ustadz.roleNames;
    final videos = ustadz.relatedVideos;
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          SecondaryHeader(
            title: 'Profil Ustadz',
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          Expanded(
            child: GradientPage(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UstadzAvatar(imageUrl: ustadz.imageUrl, size: 150),
                      const SizedBox(height: 12),

                      Text(
                        ustadz.name ?? '-',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      if (_hasText(ustadz.title)) ...[
                        const SizedBox(height: 4),
                        Text(
                          ustadz.title!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],

                      const SizedBox(height: 12),
                      _StatusPill(status: ustadz.status),

                      if (ustadz.expertiseNames.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: ustadz.expertiseNames
                              .map((e) => _MiniChip(text: e))
                              .toList(),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 18),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Informasi Umum',
                                children: [
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    value: ustadz.gender,
                                  ),
                                  _InfoRow(
                                    icon: Icons.place_outlined,
                                    value: ustadz.birthPlace,
                                  ),
                                  _InfoRow(
                                    icon: Icons.calendar_month_outlined,
                                    value: ustadz.birthDate,
                                  ),
                                  _InfoRow(
                                    icon: Icons.access_time_outlined,
                                    value: ustadz.age,
                                  ),
                                  _InfoRow(
                                    icon: Icons.translate_outlined,
                                    value: ustadz.languages,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              FutureBuilder<String?>(
                                future: AppSettingService().getAdminWhatsapp(),
                                builder: (context, snapshot) {
                                  final adminWhatsapp = snapshot.data;

                                  return _ContactSection(
                                    email: ustadz.email,
                                    adminPhone: adminWhatsapp,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SectionCard(
                            title: 'Informasi Layanan',
                            children: [
                              if (roles.isNotEmpty)
                                ...roles.map(
                                  (role) => _InfoRow(
                                    icon: UstadzIconMapper.roleIcon(role),
                                    value: role,
                                  ),
                                ),

                              if (roles.isNotEmpty &&
                                  ustadz.expertiseNames.isNotEmpty)
                                const SizedBox(height: 4),

                              if (ustadz.expertiseNames.isNotEmpty)
                                ...ustadz.expertiseNames.map(
                                  (expertise) => _InfoRow(
                                    icon: UstadzIconMapper.expertiseIcon(
                                      expertise,
                                    ),
                                    value: expertise,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (videos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final url in videos) ...[
                      YoutubePlayerCard(url: url),
                      const SizedBox(height: 12),
                    ],
                  ],

                  if (_hasText(ustadz.adminNote)) ...[
                    const SizedBox(height: 4),
                    _SectionCard(
                      title: 'Catatan Admin',
                      children: [
                        Text(
                          ustadz.adminNote!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// CONTACT SECTION
/// =======================
class _ContactSection extends StatelessWidget {
  final String? email;
  final String? adminPhone;

  const _ContactSection({required this.email, required this.adminPhone});

  @override
  Widget build(BuildContext context) {
    final phone = (adminPhone ?? '').trim();

    return _SectionCard(
      title: 'Kontak',
      children: [
        _InfoRow(
          icon: Icons.email_outlined,
          value: (email ?? '').trim().isEmpty ? '-' : email,
        ),
        const SizedBox(height: 6),
        _PrimaryActionButton(
          text: 'Hubungi Admin',
          icon: Icons.message,
          onPressed: () {
            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor admin belum tersedia.')),
              );
              return;
            }

            ContactLauncher.openWhatsApp(
              context: context,
              phoneNumber: phone,
              message: 'Assalamu\'alaikum, saya ingin menghubungi admin.',
            );
          },
        ),
        const SizedBox(height: 10),
        _OutlineActionButton(
          text: 'Kirim Email',
          icon: Icons.send_outlined,
          onPressed: () {
            ContactLauncher.sendEmail(
              context: context,
              email: email,
              subject: 'Permintaan Informasi',
              body: 'Assalamu\'alaikum,\n\nSaya ingin menghubungi Anda.\n',
            );
          },
        ),
      ],
    );
  }
}

/// =======================
/// SMALL WIDGETS
/// =======================
class UstadzAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const UstadzAvatar({super.key, required this.imageUrl, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final hasUrl = _hasText(imageUrl);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: hasUrl
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                )
              : _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    return const Center(child: Icon(Icons.person, size: 28));
  }
}

class _MiniChip extends StatelessWidget {
  final String text;

  const _MiniChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPrimaryTeal, width: 1),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: kPrimaryTeal),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String? status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final rawStatus = (status ?? '').trim();
    final normalized = rawStatus.toLowerCase();

    final isAktif = normalized == 'aktif';
    final isNonaktif = normalized == 'nonaktif';

    final borderColor = isAktif
        ? Colors.green
        : isNonaktif
        ? Colors.red
        : Theme.of(context).dividerColor;

    final bgColor = isAktif
        ? Colors.green.withOpacity(0.1)
        : isNonaktif
        ? Colors.red.withOpacity(0.1)
        : Colors.transparent;

    final textColor = isAktif
        ? Colors.green
        : isNonaktif
        ? Colors.red
        : Theme.of(context).textTheme.labelMedium?.color ?? Colors.black;

    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: rawStatus.isEmpty
          ? Text('-', style: labelStyle)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(rawStatus, style: labelStyle),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SectionCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final hasTitle = _hasText(title);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Object? value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = (value?.toString() ?? '').trim();
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: kPrimaryTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryTeal,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlineActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: kPrimaryTeal, width: 1.2),
          foregroundColor: kPrimaryTeal,
        ),
        icon: const Icon(Icons.send, size: 16, color: kPrimaryTeal),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kPrimaryTeal,
          ),
        ),
      ),
    );
  }
}

bool _hasText(String? value) => (value ?? '').trim().isNotEmpty;
