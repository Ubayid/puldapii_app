import 'package:dio/dio.dart';
import 'package:puldapii/models/prayer_day.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class PrayerService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  /// Jadwal hari ini untuk ditampilkan pada halaman Home.
  static Future<Map<String, String>> fetchPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: _dio,
      path: 'https://api.aladhan.com/v1/timings',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'method': 11,
      },
    );

    final data = body['data'];

    if (data is! Map) {
      throw const ApiFailure('Data jadwal sholat tidak valid.');
    }

    final timings = data['timings'];

    if (timings is! Map) {
      throw const ApiFailure('Data waktu sholat tidak valid.');
    }

    return _mapTimings(timings);
  }

  /// Jadwal beberapa hari ke depan untuk notifikasi.
  static Future<List<PrayerDay>> fetchPrayerCalendar({
    required double latitude,
    required double longitude,
    int totalDays = 30,
  }) async {
    final now = DateTime.now();

    final startDate = DateTime(now.year, now.month, now.day);

    final endDate = startDate.add(Duration(days: totalDays));

    final months = <DateTime>[];
    var currentMonth = DateTime(startDate.year, startDate.month);

    final lastMonth = DateTime(endDate.year, endDate.month);

    while (!currentMonth.isAfter(lastMonth)) {
      months.add(currentMonth);

      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }

    final schedules = <PrayerDay>[];

    for (final month in months) {
      final body = await ApiHelper.dioGet(
        dio: _dio,
        path:
            'https://api.aladhan.com/v1/calendar/'
            '${month.year}/${month.month}',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 11,
        },
      );

      final data = body['data'];

      if (data is! List) {
        throw const ApiFailure('Data kalender jadwal sholat tidak valid.');
      }

      for (final item in data) {
        if (item is! Map) continue;

        final dateData = item['date'];
        final timingsData = item['timings'];

        if (dateData is! Map || timingsData is! Map) {
          continue;
        }

        final gregorian = dateData['gregorian'];

        if (gregorian is! Map) continue;

        final rawDate = gregorian['date']?.toString();

        if (rawDate == null) continue;

        final date = _parseApiDate(rawDate);

        if (date == null) continue;
        if (date.isBefore(startDate)) continue;
        if (!date.isBefore(endDate)) continue;

        schedules.add(PrayerDay(date: date, timings: _mapTimings(timingsData)));
      }
    }

    schedules.sort((first, second) => first.date.compareTo(second.date));

    return schedules;
  }

  static Map<String, String> _mapTimings(Map timings) {
    return {
      'Fajr': _cleanTime(timings['Fajr']),
      'Dhuhr': _cleanTime(timings['Dhuhr']),
      'Asr': _cleanTime(timings['Asr']),
      'Maghrib': _cleanTime(timings['Maghrib']),
      'Isha': _cleanTime(timings['Isha']),
    };
  }

  static DateTime? _parseApiDate(String value) {
    final parts = value.split('-');

    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  static String _cleanTime(dynamic value) {
    final rawValue = value?.toString() ?? '-';

    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(rawValue);

    if (match == null) return '-';

    final hour = match.group(1)!.padLeft(2, '0');
    final minute = match.group(2)!;

    return '$hour:$minute';
  }
}
