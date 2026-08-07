import 'package:flutter/material.dart';

class UstadzIconMapper {
  static final Map<String, IconData> _roleIcons = {
    'pemateri kajian': Icons.mic,
    'imam': Icons.mosque,
    'muadzin': Icons.record_voice_over,
    'relawan': Icons.people,
    'khatib': Icons.headset_mic,
  };

  static final Map<String, IconData> _expertiseIcons = {
    'tafsir': Icons.menu_book,
    'hadist': Icons.library_books,
    'fiqih': Icons.gavel,
    'aqidah': Icons.shield_outlined,
    'akhlak': Icons.favorite_outline,
    'bahasa arab': Icons.translate,
  };

  static IconData roleIcon(String? roleName) {
    final key = (roleName ?? '').toLowerCase().trim();
    return _roleIcons[key] ?? Icons.work_outline;
  }

  static IconData expertiseIcon(String? expertiseName) {
    final key = (expertiseName ?? '').toLowerCase().trim();
    return _expertiseIcons[key] ?? Icons.auto_awesome_outlined;
  }
}
