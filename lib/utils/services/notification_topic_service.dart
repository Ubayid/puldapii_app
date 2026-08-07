import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationTopicService {
  NotificationTopicService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool _initialized = false;

  static Future<void> initializeTopics() async {
    if (_initialized) return;

    if (kIsWeb) {
      debugPrint(
        'Subscribe topic dilewati: '
        'tidak didukung di Flutter Web.',
      );

      return;
    }

    // Tidak meminta permission di sini.
    // Permission sudah ditangani oleh
    // FirebaseNotificationService.init().
    await _messaging.subscribeToTopic('tebar_buku');

    await _messaging.subscribeToTopic('kajian');

    await _messaging.subscribeToTopic('poster_dakwah');

    _initialized = true;

    debugPrint('Subscribe topic FCM berhasil.');
  }

  static Future<void> unsubscribeAllTopics() async {
    if (kIsWeb) {
      debugPrint(
        'Unsubscribe topic dilewati: '
        'tidak didukung di Flutter Web.',
      );

      return;
    }

    await _messaging.unsubscribeFromTopic('tebar_buku');

    await _messaging.unsubscribeFromTopic('kajian');

    await _messaging.unsubscribeFromTopic('poster_dakwah');

    _initialized = false;
  }
}
