import 'package:flutter/material.dart';
import 'package:puldapii/models/ustadz_model.dart';
import 'package:puldapii/pages/home/pages/dakwah_sdm/ustadz_profile.dart';

class UstadzListCard extends StatelessWidget {
  final UstadzModel ustadz;

  const UstadzListCard({super.key, required this.ustadz});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (ustadz.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;
    final expertises = ustadz.expertiseNames.take(3).toList();
    final statusText = (ustadz.status ?? '').trim();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UstadzDetailPage(ustadz: ustadz)),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(hasImage, imageUrl),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ustadz.name ?? '-',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            if ((ustadz.title ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                ustadz.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (statusText.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _statusChip(statusText),
                      ],
                    ],
                  ),

                  if (expertises.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...expertises.map((e) => _expertiseChip(e)),
                        if (ustadz.expertiseNames.length > 3)
                          _expertiseChip(
                            '+${ustadz.expertiseNames.length - 3}',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool hasImage, String imageUrl) {
    return ClipOval(
      child: hasImage
          ? Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackAvatar(),
            )
          : _fallbackAvatar(),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFF3F4F6),
      child: const Icon(Icons.person, size: 30, color: Colors.grey),
    );
  }

  Widget _expertiseChip(String text) {
    const primary = Color.fromRGBO(68, 174, 183, 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primary.withOpacity(0.22)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase().trim();
    final isAktif = s == 'aktif';
    final isNonaktif = s == 'nonaktif';

    final textColor = isAktif
        ? Colors.green
        : isNonaktif
        ? Colors.red
        : Colors.grey.shade700;

    final bgColor = isAktif
        ? Colors.green.withOpacity(0.10)
        : isNonaktif
        ? Colors.red.withOpacity(0.10)
        : Colors.grey.withOpacity(0.10);

    final borderColor = isAktif
        ? Colors.green.withOpacity(0.22)
        : isNonaktif
        ? Colors.red.withOpacity(0.22)
        : Colors.grey.withOpacity(0.22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
