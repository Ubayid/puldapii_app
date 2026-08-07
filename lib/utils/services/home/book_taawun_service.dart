import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookTaawunService {
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

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  Future<Options> _options({bool multipart = false}) async {
    final token = await _getToken();

    return Options(
      headers: {
        'Accept': 'application/json',
        if (token != null && token.trim().isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      contentType: multipart
          ? Headers.multipartFormDataContentType
          : Headers.jsonContentType,
    );
  }

  String _fileNameFromXFile(XFile file) {
    final name = file.name.trim();

    if (name.isNotEmpty) {
      return name;
    }

    final path = file.path;
    final parts = path.split('/');

    if (parts.isNotEmpty && parts.last.trim().isNotEmpty) {
      return parts.last;
    }

    return 'payment_proof.jpg';
  }

  Future<Map<String, dynamic>> getTaawuns({
    String? status,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    return ApiHelper.dioGet(
      dio: _dio,
      path: '/book-taawuns',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'per_page': perPage,
      },
      options: await _options(),
    );
  }

  Future<Map<String, dynamic>> getActiveBooks() async {
    return ApiHelper.dioGet(
      dio: _dio,
      path: '/book-taawuns/books',
      options: await _options(),
    );
  }

  Future<Map<String, dynamic>> getBankAccount() async {
    return ApiHelper.dioGet(
      dio: _dio,
      path: '/book-taawuns/bank-account',
      options: await _options(),
    );
  }

  Future<Map<String, dynamic>> createTaawun({
    required int bookId,
    required String donorName,
    required String donorWhatsapp,
    String? donorEmail,
    required int amount,
  }) async {
    return ApiHelper.dioPost(
      dio: _dio,
      path: '/book-taawuns',
      data: {
        'book_id': bookId,
        'donor_name': donorName,
        'donor_whatsapp': donorWhatsapp,
        'donor_email': donorEmail,
        'amount': amount,
      },
      options: await _options(),
    );
  }

  Future<Map<String, dynamic>> getTaawunDetail(int id) async {
    return ApiHelper.dioGet(
      dio: _dio,
      path: '/book-taawuns/$id',
      options: await _options(),
    );
  }

  Future<Map<String, dynamic>> updateTaawun({
    required int id,
    required int bookId,
    required String donorName,
    required String donorWhatsapp,
    String? donorEmail,
    required int amount,
    XFile? paymentProof,
    bool removePaymentProof = false,
  }) async {
    final formData = FormData.fromMap({
      'book_id': bookId.toString(),
      'donor_name': donorName,
      'donor_whatsapp': donorWhatsapp,
      'amount': amount.toString(),
      'remove_payment_proof': removePaymentProof ? '1' : '0',
      if (donorEmail != null && donorEmail.trim().isNotEmpty)
        'donor_email': donorEmail.trim(),
    });

    if (paymentProof != null) {
      final Uint8List bytes = await paymentProof.readAsBytes();

      formData.files.add(
        MapEntry(
          'payment_proof',
          MultipartFile.fromBytes(
            bytes,
            filename: _fileNameFromXFile(paymentProof),
          ),
        ),
      );
    }

    return ApiHelper.dioPostMultipart(
      dio: _dio,
      path: '/book-taawuns/$id/update',
      formData: formData,
      options: await _options(multipart: true),
    );
  }

  Future<Map<String, dynamic>> cancelTaawun(int id) async {
    return ApiHelper.dioPost(
      dio: _dio,
      path: '/book-taawuns/$id/cancel',
      options: await _options(),
    );
  }
}
