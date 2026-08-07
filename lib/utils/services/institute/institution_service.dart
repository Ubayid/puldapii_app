import 'package:dio/dio.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:puldapii/config/api_client.dart';

class InstitutionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      responseType: ResponseType.json,
    ),
  );

  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();

    final token =
        prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');

    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null && token.trim().isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getInstitutions({
    String? q,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await ApiHelper.dioGet(
      dio: _dio,
      path: '/institutions',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      },
      options: await _authOptions(),
    );

    return response;
  }

  Future<Map<String, dynamic>> getInstitutionDetail(int id) async {
    final response = await ApiHelper.dioGet(
      dio: _dio,
      path: '/institutions/$id',
      options: await _authOptions(),
    );

    return response;
  }

  Future<Map<String, dynamic>> getInstitutionStats() async {
    final body = await ApiHelper.dioGet(dio: _dio, path: '/institutions/stats');

    return Map<String, dynamic>.from(body);
  }
}
