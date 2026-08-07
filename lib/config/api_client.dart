import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // static const String baseUrl = 'http://127.0.0.1:8000';
  static const String baseUrl = 'https://layanan.puldapii.or.id';

  static String get apiBaseUrl => '$baseUrl/api';
}

class ApiClient {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('auth_token');

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              handler.next(options);
            },
          ),
        );
}
