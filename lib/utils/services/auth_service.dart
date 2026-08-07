import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = ApiConfig.apiBaseUrl;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  Future<void> removeRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }

  String? _extractToken(Map<String, dynamic> data) {
    if (data['token'] != null) {
      return data['token'].toString();
    }

    if (data['access_token'] != null) {
      return data['access_token'].toString();
    }

    if (data['data'] is Map && data['data']['token'] != null) {
      return data['data']['token'].toString();
    }

    if (data['data'] is Map && data['data']['access_token'] != null) {
      return data['data']['access_token'].toString();
    }

    return null;
  }

  String? _extractRole(Map<String, dynamic> data) {
    if (data['user'] is Map && data['user']['role'] != null) {
      return data['user']['role'].toString();
    }

    if (data['data'] is Map &&
        data['data']['user'] is Map &&
        data['data']['user']['role'] != null) {
      return data['data']['user']['role'].toString();
    }

    if (data['data'] is Map && data['data']['role'] != null) {
      return data['data']['role'].toString();
    }

    return null;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    final data = Map<String, dynamic>.from(response.data);

    print('LOGIN RESPONSE: $data');

    final token = _extractToken(data);
    final role = _extractRole(data);

    print('LOGIN TOKEN: $token');
    print('LOGIN ROLE: $role');

    if (token != null && token.isNotEmpty) {
      await saveToken(token);

      final savedToken = await getToken();
      print('SAVED LOGIN TOKEN: $savedToken');
    }

    if (role != null && role.isNotEmpty) {
      await saveRole(role);

      final savedRole = await getRole();
      print('SAVED LOGIN ROLE: $savedRole');
    }

    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = Map<String, dynamic>.from(response.data);

    print('REGISTER RESPONSE: $data');

    final token = _extractToken(data);

    print('REGISTER TOKEN: $token');

    if (token != null && token.isNotEmpty) {
      await saveToken(token);

      final savedToken = await getToken();
      print('SAVED REGISTER TOKEN: $savedToken');
    }

    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final token = await getToken();

    final response = await _dio.get(
      '/me',
      queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ),
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> logout() async {
    final token = await getToken();

    try {
      await _dio.post(
        '/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } finally {
      await removeToken();
      await removeRole();
    }
  }

  Future<void> testSaveFcmToken() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      print('AUTH TOKEN KOSONG, LOGIN DULU');
      return;
    }

    final testFcmToken =
        'test_fcm_token_dari_flutter_web_${DateTime.now().millisecondsSinceEpoch}';

    final response = await _dio.post(
      '/fcm-token',
      data: {'fcm_token': testFcmToken},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    print('TEST FCM TOKEN DIKIRIM: $testFcmToken');
    print('RESPONSE TEST FCM TOKEN: ${response.data}');
  }
}
