import 'package:dio/dio.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsultationDetailService {
  static const String baseUrl = 'https://layanan.puldapii.or.id/api';

  final Dio _dio;

  ConsultationDetailService({Dio? dio})
    : _dio =
          dio ??
          Dio(
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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');
  }

  Future<Options> _options() async {
    final token = await _getToken();

    return Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getMyConsultationDetail(int id) async {
    final body = await ApiHelper.dioGet(
      dio: _dio,
      path: '/my-consultations/$id',
      options: await _options(),
    );

    if (body['success'] != true) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal mengambil detail konsultasi',
      );
    }

    final data = body['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const ApiFailure('Data detail konsultasi tidak valid.');
  }
}
