import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _localNotificationInitialized = false;
  static bool _firebaseListenerInitialized = false;

  static const String generalChannelId = 'general_notification_v1';
  static const String generalChannelName = 'Notifikasi Umum';
  static const String generalChannelDescription =
      'Poster, berita, pengumuman, dan notifikasi umum';

  static const String consultChannelId = 'consultation_channel_v2';
  static const String consultChannelName = 'Konsultasi';
  static const String consultChannelDescription =
      'Notifikasi jawaban konsultasi PULDAPII App';

  static const String kajianChannelId = 'kajian_ongoing_channel_v2';
  static const String kajianChannelName = 'Kajian Hari Ini';
  static const String kajianChannelDescription =
      'Notifikasi kajian yang aktif sampai waktu kajian selesai';

  /// Seluruh channel Firebase memakai badge/titik ikon aplikasi.
  static const AndroidNotificationChannel generalChannel =
      AndroidNotificationChannel(
        generalChannelId,
        generalChannelName,
        description: generalChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  static const AndroidNotificationChannel consultChannel =
      AndroidNotificationChannel(
        consultChannelId,
        consultChannelName,
        description: consultChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  static const AndroidNotificationChannel kajianChannel =
      AndroidNotificationChannel(
        kajianChannelId,
        kajianChannelName,
        description: kajianChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  static final Map<int, Timer> _kajianTimers = {};

  static void Function(Map<String, dynamic> data)? onNotificationTap;

  static Map<String, dynamic>? _pendingNotificationData;

  static Future<void> initializeLocalNotifications() async {
    await _initLocalNotification();
  }

  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotification();

    if (!_firebaseListenerInitialized) {
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);

      _messaging.onTokenRefresh.listen((token) async {
        await saveTokenToBackend(token: token);
      });

      _firebaseListenerInitialized = true;
    }

    await saveTokenToBackend();
  }

  static void setNotificationTapHandler(
    void Function(Map<String, dynamic> data) handler,
  ) {
    onNotificationTap = handler;

    final pendingData = _pendingNotificationData;

    if (pendingData != null) {
      _pendingNotificationData = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        handler(pendingData);
      });
    }
  }

  static void removeNotificationTapHandler() {
    onNotificationTap = null;
  }

  static void _dispatchNotificationTap(Map<String, dynamic> data) {
    final handler = onNotificationTap;

    if (handler != null) {
      handler(data);
    } else {
      _pendingNotificationData = data;
    }
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> _initLocalNotification() async {
    if (_localNotificationInitialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;

        if (payload == null || payload.isEmpty) {
          return;
        }

        try {
          final decoded = jsonDecode(payload);

          if (decoded is! Map) {
            return;
          }

          final data = Map<String, dynamic>.from(decoded);

          debugPrint('LOCAL NOTIFICATION CLICK: $data');

          _dispatchNotificationTap(data);
        } catch (error) {
          debugPrint('Payload local notification tidak valid: $error');
        }
      },
    );

    await _readLocalNotificationLaunchPayload();
    await _createAndroidChannels();

    _localNotificationInitialized = true;
  }

  static Future<void> _readLocalNotificationLaunchPayload() async {
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();

    final launchedFromNotification =
        launchDetails?.didNotificationLaunchApp ?? false;

    final launchPayload = launchDetails?.notificationResponse?.payload;

    if (!launchedFromNotification ||
        launchPayload == null ||
        launchPayload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(launchPayload);

      if (decoded is Map) {
        _pendingNotificationData = Map<String, dynamic>.from(decoded);
      }
    } catch (error) {
      debugPrint('Launch payload tidak valid: $error');
    }
  }

  static Future<void> _createAndroidChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(generalChannel);

    await androidPlugin.createNotificationChannel(consultChannel);

    await androidPlugin.createNotificationChannel(kajianChannel);
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    await _initLocalNotification();

    final type = message.data['type']?.toString() ?? '';

    if (type == 'dakwah_ongoing') {
      await showOngoingDakwahNotification(message.data);
      return;
    }

    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'PULDAPII App';

    final body =
        message.notification?.body ??
        message.data['body']?.toString() ??
        'Ada notifikasi baru';

    final isConsultation =
        type == 'consultation_answered' || type == 'consultation';

    final androidDetails = AndroidNotificationDetails(
      isConsultation ? consultChannelId : generalChannelId,
      isConsultation ? consultChannelName : generalChannelName,
      channelDescription: isConsultation
          ? consultChannelDescription
          : generalChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,

      // Notifikasi Firebase membuat badge/titik ikon Android.
      channelShowBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await _localNotifications.show(
      id: _generateNotificationId(),
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  static int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  }

  static Future<void> saveTokenToBackend({String? token}) async {
    try {
      debugPrint('Memanggil saveTokenToBackend()');

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        debugPrint('User belum login, FCM token belum dikirim.');
        return;
      }

      final fcmToken = token ?? await _messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('FCM token kosong.');
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.apiBaseUrl,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      final response = await dio.post(
        '/fcm-token',
        data: {'fcm_token': fcmToken},
      );

      debugPrint('FCM token berhasil dikirim ke API.');

      debugPrint('Respons simpan FCM token: ${response.data}');
    } catch (error) {
      debugPrint('Gagal mengirim FCM token: $error');
    }
  }

  static Future<void> showOngoingDakwahNotification(
    Map<String, dynamic> data,
  ) async {
    await _initLocalNotification();

    final dakwahId = int.tryParse(data['dakwah_id']?.toString() ?? '');

    final endAtRaw = data['end_at']?.toString();

    if (dakwahId == null || endAtRaw == null || endAtRaw.isEmpty) {
      debugPrint('Data ongoing kajian tidak lengkap: $data');
      return;
    }

    final endAt = DateTime.tryParse(endAtRaw)?.toLocal();

    if (endAt == null) {
      debugPrint('Format end_at tidak valid: $endAtRaw');
      return;
    }

    if (!DateTime.now().isBefore(endAt)) {
      await _localNotifications.cancel(id: dakwahId);
      return;
    }

    final kajianTitle = data['title']?.toString().trim() ?? '';

    final ustadzName = data['ustadz_name']?.toString().trim() ?? '';

    final time = data['time']?.toString().trim() ?? '';

    var notificationBody = kajianTitle;

    if (ustadzName.isNotEmpty) {
      notificationBody += ' bersama $ustadzName';
    }

    if (time.isNotEmpty) {
      notificationBody += ' • $time';
    }

    if (notificationBody.trim().isEmpty) {
      notificationBody = 'Ada kajian yang diselenggarakan hari ini';
    }

    final timeoutMilliseconds = endAt.difference(DateTime.now()).inMilliseconds;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        kajianChannelId,
        kajianChannelName,
        channelDescription: kajianChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        timeoutAfter: timeoutMilliseconds,
        category: AndroidNotificationCategory.event,
        visibility: NotificationVisibility.public,
        channelShowBadge: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await _localNotifications.show(
      id: dakwahId,
      title: 'Kajian Hari Ini',
      body: notificationBody,
      notificationDetails: details,
      payload: jsonEncode({
        ...data,
        'type': 'dakwah_ongoing',
        'dakwah_id': dakwahId.toString(),
      }),
    );

    _scheduleKajianCancellation(notificationId: dakwahId, endAt: endAt);
  }

  static void _scheduleKajianCancellation({
    required int notificationId,
    required DateTime endAt,
  }) {
    _kajianTimers[notificationId]?.cancel();

    final duration = endAt.difference(DateTime.now());

    if (duration <= Duration.zero) {
      _cancelKajianNotification(notificationId);
      return;
    }

    _kajianTimers[notificationId] = Timer(duration, () {
      _cancelKajianNotification(notificationId);
    });
  }

  static Future<void> _cancelKajianNotification(int notificationId) async {
    await _localNotifications.cancel(id: notificationId);

    _kajianTimers[notificationId]?.cancel();
    _kajianTimers.remove(notificationId);

    debugPrint(
      'Notifikasi kajian ID $notificationId '
      'dihapus karena kajian selesai.',
    );
  }
}
