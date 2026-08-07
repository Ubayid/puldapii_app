import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:puldapii/utils/services/home/prayer_notification_service.dart';
import 'package:puldapii/utils/services/home/prayer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String prayerUpdateTask = 'prayer_schedule_update';

const String prayerPeriodicTaskId = 'puldapii_prayer_periodic_update';

const String prayerOneOffTaskId = 'puldapii_prayer_initial_update';

@pragma('vm:entry-point')
void prayerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (task != prayerUpdateTask) {
      return Future.value(true);
    }

    try {
      final preferences = await SharedPreferences.getInstance();

      final latitude = preferences.getDouble(
        PrayerBackgroundService.latitudeKey,
      );

      final longitude = preferences.getDouble(
        PrayerBackgroundService.longitudeKey,
      );

      if (latitude == null || longitude == null) {
        debugPrint(
          'Background jadwal sholat dilewati: '
          'koordinat belum tersimpan.',
        );

        return Future.value(true);
      }

      await PrayerNotificationService.initialize();

      // iOS maksimal sekitar 64 notifikasi pending.
      // 12 hari × 5 waktu = 60 notifikasi.
      final totalDays = Platform.isIOS ? 12 : 30;

      final schedules = await PrayerService.fetchPrayerCalendar(
        latitude: latitude,
        longitude: longitude,
        totalDays: totalDays,
      );

      if (schedules.isEmpty) {
        debugPrint(
          'Background jadwal sholat gagal: '
          'jadwal dari API kosong.',
        );

        return Future.value(false);
      }

      await PrayerNotificationService.schedulePrayerCalendar(
        schedules: schedules,
      );

      await preferences.setString(
        PrayerBackgroundService.lastUpdateKey,
        DateTime.now().toIso8601String(),
      );

      final pending =
          await PrayerNotificationService.getPendingPrayerNotifications();

      debugPrint(
        'Background jadwal sholat berhasil. '
        'Pending adzan: ${pending.length}',
      );

      return Future.value(true);
    } catch (error, stackTrace) {
      debugPrint('Background jadwal sholat gagal: $error');

      debugPrintStack(stackTrace: stackTrace);

      // Workmanager dapat mencoba kembali.
      return Future.value(false);
    }
  });
}

class PrayerBackgroundService {
  PrayerBackgroundService._();

  static bool _initialized = false;

  static const String latitudeKey = 'prayer_last_latitude';

  static const String longitudeKey = 'prayer_last_longitude';

  static const String lastUpdateKey = 'prayer_last_update';

  static Future<void> initialize() async {
    if (_initialized) return;

    await Workmanager().initialize(prayerCallbackDispatcher);

    await Workmanager().registerPeriodicTask(
      prayerPeriodicTaskId,
      prayerUpdateTask,

      // Android tidak menjamin dijalankan tepat pada jam tertentu,
      // tetapi akan menjalankannya secara berkala.
      frequency: const Duration(hours: 24),

      initialDelay: const Duration(minutes: 15),

      constraints: Constraints(networkType: NetworkType.connected),

      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );

    _initialized = true;

    debugPrint('Background pembaruan jadwal sholat aktif.');
  }

  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setDouble(latitudeKey, latitude);

    await preferences.setDouble(longitudeKey, longitude);
  }

  static Future<void> runNow() async {
    await initialize();

    await Workmanager().registerOneOffTask(
      prayerOneOffTaskId,
      prayerUpdateTask,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
