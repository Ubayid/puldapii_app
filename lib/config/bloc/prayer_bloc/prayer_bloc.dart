import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:puldapii/utils/services/home/prayer_background_service.dart';
import 'package:puldapii/utils/services/home/prayer_notification_service.dart';
import 'package:puldapii/utils/services/home/prayer_service.dart';

part 'prayer_event.dart';
part 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  PrayerBloc() : super(PrayerInitial()) {
    on<LoadPrayerSchedule>(_onLoadPrayerSchedule);

    on<RefreshPrayerSchedule>(_onRefreshPrayerSchedule);

    on<PrayerTicked>(_onPrayerTicked);
  }

  final Geocoding _geocoding = Geocoding();
  Timer? _timer;

  final List<Map<String, String>> prayerOrder = const [
    {'name': 'Subuh', 'key': 'Fajr'},
    {'name': 'Zuhur', 'key': 'Dhuhr'},
    {'name': 'Asar', 'key': 'Asr'},
    {'name': 'Magrib', 'key': 'Maghrib'},
    {'name': 'Isya', 'key': 'Isha'},
  ];

  Future<void> _onLoadPrayerSchedule(
    LoadPrayerSchedule event,
    Emitter<PrayerState> emit,
  ) async {
    await _loadPrayer(emit);
  }

  Future<void> _onRefreshPrayerSchedule(
    RefreshPrayerSchedule event,
    Emitter<PrayerState> emit,
  ) async {
    await _loadPrayer(emit);
  }

  Future<void> _onPrayerTicked(
    PrayerTicked event,
    Emitter<PrayerState> emit,
  ) async {
    if (state is! PrayerLoaded) return;

    final currentState = state as PrayerLoaded;

    final result = _calculateCurrentPrayer(currentState.prayerTimes);

    emit(
      currentState.copyWith(
        currentPrayerName: result.name,
        currentPrayerTime: result.time,
        remainingMinutes: result.remainingMinutes,
      ),
    );
  }

  Future<void> _loadPrayer(Emitter<PrayerState> emit) async {
    try {
      emit(PrayerLoading());

      // Lokasi hanya diambil satu kali di sini.
      final position = await _determinePosition();

      final locationName = await _getLocationName(position);

      final prayerTimes = await PrayerService.fetchPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final result = _calculateCurrentPrayer(prayerTimes);

      emit(
        PrayerLoaded(
          locationName: locationName,
          prayerTimes: prayerTimes,
          currentPrayerName: result.name,
          currentPrayerTime: result.time,
          remainingMinutes: result.remainingMinutes,
        ),
      );

      _startTimer();

      await _preparePrayerNotifications(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (error) {
      emit(PrayerError(message: _cleanError(error)));
    }
  }

  Future<void> _preparePrayerNotifications({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await PrayerBackgroundService.saveLocation(
        latitude: latitude,
        longitude: longitude,
      );

      final allowed = await PrayerNotificationService.requestPermission();

      if (!allowed) {
        debugPrint(
          'Notifikasi salat tidak dijadwalkan '
          'karena izin belum diberikan.',
        );

        return;
      }

      final totalDays = Platform.isIOS ? 12 : 30;

      final schedules = await PrayerService.fetchPrayerCalendar(
        latitude: latitude,
        longitude: longitude,
        totalDays: totalDays,
      );

      await PrayerNotificationService.schedulePrayerCalendar(
        schedules: schedules,
      );

      final pending =
          await PrayerNotificationService.getPendingPrayerNotifications();

      debugPrint('Notifikasi sholat tersimpan: ${pending.length}');

      if (pending.isEmpty) {
        throw Exception(
          'Tidak ada notifikasi sholat yang berhasil dijadwalkan.',
        );
      }

      await PrayerNotificationService.printPendingNotifications();
    } catch (error, stackTrace) {
      debugPrint(
        'Gagal menyiapkan notifikasi salat: '
        '$error',
      );

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('GPS belum diaktifkan.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. '
        'Aktifkan izin lokasi melalui '
        'pengaturan aplikasi.',
      );
    }

    final lastPosition = await Geolocator.getLastKnownPosition();

    if (lastPosition != null) {
      return lastPosition;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  Future<String> _getLocationName(Position position) async {
    if (kIsWeb) return 'Lokasi Anda';

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        locale: const Locale('id', 'ID'),
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        return place.subAdministrativeArea ??
            place.locality ??
            place.administrativeArea ??
            'Lokasi Anda';
      }
    } catch (error) {
      debugPrint('Gagal membaca nama lokasi: $error');
    }

    return 'Lokasi Anda';
  }

  _PrayerResult _calculateCurrentPrayer(Map<String, String> prayerTimes) {
    final now = DateTime.now();

    for (final prayer in prayerOrder) {
      final key = prayer['key'];
      final rawTime = prayerTimes[key];

      if (rawTime == null) continue;

      final parsedTime = _parsePrayerTime(rawTime, now);

      if (parsedTime == null) continue;

      if (now.isBefore(parsedTime)) {
        return _PrayerResult(
          name: prayer['name']!,
          time: _cleanPrayerTime(rawTime),
          remainingMinutes: parsedTime.difference(now).inMinutes,
        );
      }
    }

    final fajrRaw = prayerTimes['Fajr'] ?? '00:00';

    final cleanFajr = _cleanPrayerTime(fajrRaw);

    final fajrParts = cleanFajr.split(':');

    final tomorrowFajr = DateTime(
      now.year,
      now.month,
      now.day + 1,
      int.tryParse(fajrParts[0]) ?? 0,
      int.tryParse(fajrParts[1]) ?? 0,
    );

    return _PrayerResult(
      name: 'Subuh',
      time: cleanFajr,
      remainingMinutes: tomorrowFajr.difference(now).inMinutes,
    );
  }

  DateTime? _parsePrayerTime(String value, DateTime date) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);

    if (match == null) return null;

    final hour = int.tryParse(match.group(1) ?? '');

    final minute = int.tryParse(match.group(2) ?? '');

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _cleanPrayerTime(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);

    if (match == null) return value;

    return '${match.group(1)!.padLeft(2, '0')}:'
        '${match.group(2)!}';
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => add(PrayerTicked()),
    );
  }

  static String formatRemainingTime(int minutes) {
    if (minutes <= 0) {
      return '(sedang berlangsung)';
    }

    if (minutes < 60) {
      return '($minutes menit lagi)';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '($hours jam lagi)';
    }

    return '($hours jam '
        '$remainingMinutes menit lagi)';
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }

  @override
  Future<void> close() {
    _timer?.cancel();

    return super.close();
  }
}

class _PrayerResult {
  final String name;
  final String time;
  final int remainingMinutes;

  const _PrayerResult({
    required this.name,
    required this.time,
    required this.remainingMinutes,
  });
}
