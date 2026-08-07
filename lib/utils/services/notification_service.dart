import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:puldapii/models/app_notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String baseUrl = 'https://layanan.puldapii.or.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    // Sesuaikan key token dengan yang kamu pakai saat login.
    // Kalau di AuthService kamu key-nya beda, ganti 'token' ini.
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> getNotifications({int page = 1}) async {
    final headers = await _headers();

    final uri = Uri.parse('$baseUrl/notifications?page=$page');

    final response = await http.get(uri, headers: headers);

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List data = body['data']['data'] ?? [];

      return data.map((item) => AppNotification.fromJson(item)).toList();
    }

    throw Exception(body['message'] ?? 'Gagal mengambil notifikasi');
  }

  Future<int> getUnreadCount() async {
    final headers = await _headers();

    final uri = Uri.parse('$baseUrl/notifications/unread-count');

    final response = await http.get(uri, headers: headers);

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return body['data']['unread_count'] ?? 0;
    }

    throw Exception(body['message'] ?? 'Gagal mengambil jumlah notifikasi');
  }

  Future<void> markAsRead(int notificationId) async {
    final headers = await _headers();

    final uri = Uri.parse('$baseUrl/notifications/$notificationId/read');

    final response = await http.post(uri, headers: headers);

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return;
    }

    throw Exception(body['message'] ?? 'Gagal menandai notifikasi');
  }

  Future<void> markAllAsRead() async {
    final headers = await _headers();

    final uri = Uri.parse('$baseUrl/notifications/read-all');

    final response = await http.post(uri, headers: headers);

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return;
    }

    throw Exception(body['message'] ?? 'Gagal menandai semua notifikasi');
  }
}
