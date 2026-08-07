import 'package:intl/intl.dart';

String formatTanggalIndo(String isoDate) {
  if (isoDate.trim().isEmpty) return '-';
  try {
    final dt = DateTime.parse(isoDate); // "2024-05-20"
    return DateFormat('EEEE, d MMMM y', 'id_ID').format(dt);
    // contoh: "Senin, 20 Mei 2024"
  } catch (_) {
    return isoDate; // fallback kalau format tidak valid
  }
}
