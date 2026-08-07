import 'package:flutter/material.dart';
import 'card_container.dart';

class MushafInfoCard extends StatelessWidget {
  final int? currentJuz;
  final String currentSurahName;
  final int totalAyah;

  const MushafInfoCard({
    super.key,
    required this.currentJuz,
    required this.currentSurahName,
    required this.totalAyah,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              currentJuz != null ? 'Juz $currentJuz' : '-',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              currentSurahName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$totalAyah Ayat',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
