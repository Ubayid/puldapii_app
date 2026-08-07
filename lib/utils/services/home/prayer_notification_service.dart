import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:puldapii/models/prayer_day.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class PrayerNotificationService {
  PrayerNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const String prayerChannelId = 'prayer_notification_v6';

  static const String prayerChannelName = 'Pengingat Waktu Sholat';

  static const String prayerChannelDescription =
      'Notifikasi masuk waktu sholat';

  /// Channel sholat tidak membuat badge/titik pada ikon aplikasi.
  static const AndroidNotificationChannel prayerChannel =
      AndroidNotificationChannel(
        prayerChannelId,
        prayerChannelName,
        description: prayerChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: false,
      );

  static const Map<String, String> _prayerNames = {
    'Fajr': 'Subuh',
    'Dhuhr': 'Zuhur',
    'Asr': 'Asar',
    'Maghrib': 'Magrib',
    'Isha': 'Isya',
  };

  static const NotificationDetails _prayerNotificationDetails =
      NotificationDetails(
        android: AndroidNotificationDetails(
          prayerChannelId,
          prayerChannelName,
          channelDescription: prayerChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          playSound: true,
          enableVibration: true,

          // Tidak membuat badge/titik pada ikon aplikasi Android.
          channelShowBadge: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
          badgeNumber: 0,
        ),
      );

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    await _setLocalTimezone();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _notifications.initialize(settings: settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(prayerChannel);

    _initialized = true;

    debugPrint('PrayerNotificationService aktif. Timezone: ${tz.local.name}');
  }

  static Future<void> _setLocalTimezone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (error) {
      debugPrint('Gagal membaca timezone perangkat: $error');

      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
  }

  static Future<bool> requestPermission() async {
    await initialize();

    var notificationAllowed = true;
    var exactAlarmAllowed = true;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final exactAlarmPermission = await androidPlugin
          .requestExactAlarmsPermission();

      if (exactAlarmPermission != null) {
        exactAlarmAllowed = exactAlarmPermission;
      }
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final iosPermission = await iosPlugin.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );

      if (iosPermission != null) {
        notificationAllowed = iosPermission;
      }
    }

    return notificationAllowed && exactAlarmAllowed;
  }

  static Future<void> schedulePrayerCalendar({
    required List<PrayerDay> schedules,
  }) async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final prayerKeys = _prayerNames.keys.toList();

    var scheduledCount = 0;

    for (final day in schedules) {
      for (
        var prayerIndex = 0;
        prayerIndex < prayerKeys.length;
        prayerIndex++
      ) {
        final prayerKey = prayerKeys[prayerIndex];
        final prayerName = _prayerNames[prayerKey]!;
        final rawTime = day.timings[prayerKey];

        if (rawTime == null || rawTime.trim().isEmpty || rawTime == '-') {
          continue;
        }

        final time = _parseTime(rawTime);

        if (time == null) {
          debugPrint('Waktu $prayerKey tidak valid: $rawTime');
          continue;
        }

        final scheduledDate = tz.TZDateTime(
          tz.local,
          day.date.year,
          day.date.month,
          day.date.day,
          time.hour,
          time.minute,
        );

        if (!scheduledDate.isAfter(now)) {
          continue;
        }

        final notificationId = _generateNotificationId(
          date: day.date,
          prayerIndex: prayerIndex,
        );

        await _notifications.zonedSchedule(
          id: notificationId,
          title: 'Sholat $prayerName • $rawTime',
          body:
              'Telah masuk waktu sholat $prayerName pukul $rawTime. '
              'Mari segera menunaikan sholat.',
          scheduledDate: scheduledDate,
          notificationDetails: _prayerNotificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'prayer:$prayerKey:${day.date.toIso8601String()}',
        );

        scheduledCount++;
      }
    }

    debugPrint('$scheduledCount notifikasi sholat berhasil dijadwalkan.');
  }

  static int _generateNotificationId({
    required DateTime date,
    required int prayerIndex,
  }) {
    return (date.year * 100000) +
        (date.month * 1000) +
        (date.day * 10) +
        prayerIndex;
  }

  static _PrayerTime? _parseTime(String value) {
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

    return _PrayerTime(hour: hour, minute: minute);
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    await initialize();

    return _notifications.pendingNotificationRequests();
  }

  static Future<void> printPendingNotifications() async {
    final pending = await getPendingNotifications();

    debugPrint('Jumlah seluruh notifikasi pending: ${pending.length}');

    for (final notification in pending) {
      debugPrint(
        'PENDING: '
        'id=${notification.id}, '
        'title=${notification.title}, '
        'payload=${notification.payload}',
      );
    }
  }

  static Future<List<PendingNotificationRequest>>
  getPendingPrayerNotifications() async {
    await initialize();

    final pending = await _notifications.pendingNotificationRequests();

    return pending.where((notification) {
      final payload = notification.payload ?? '';

      return payload.startsWith('prayer:');
    }).toList();
  }

  static Future<void> showScheduledTestNotification() async {
    await initialize();

    final allowed = await requestPermission();

    if (!allowed) {
      throw Exception('Izin notifikasi atau alarm presisi belum diberikan.');
    }

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(minutes: 1));

    const testNotificationId = 999999;

    await _notifications.cancel(id: testNotificationId);

    await _notifications.zonedSchedule(
      id: testNotificationId,
      title: 'Tes Notifikasi Sholat',
      body:
          'Notifikasi sholat terjadwal berhasil muncul '
          'tanpa badge aplikasi.',
      scheduledDate: scheduledDate,
      notificationDetails: _prayerNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'prayer:test',
    );

    debugPrint('Tes notifikasi sholat dijadwalkan pada $scheduledDate');
  }

  static Future<void> cancelPrayerNotification({
    required DateTime date,
    required int prayerIndex,
  }) async {
    await initialize();

    final notificationId = _generateNotificationId(
      date: date,
      prayerIndex: prayerIndex,
    );

    await _notifications.cancel(id: notificationId);
  }

  static Future<void> cancelAllPrayerNotifications() async {
    await initialize();

    final pending = await getPendingNotifications();

    for (final notification in pending) {
      final payload = notification.payload ?? '';

      if (payload.startsWith('prayer:')) {
        await _notifications.cancel(id: notification.id);
      }
    }
  }
}

class _PrayerTime {
  final int hour;
  final int minute;

  const _PrayerTime({required this.hour, required this.minute});
}
