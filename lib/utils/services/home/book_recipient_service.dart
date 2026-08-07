import 'dart:io';

import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/book_recipient_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class BookRecipientService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      responseType: ResponseType.json,
    ),
  );

  static Options _authOptions(String token, {bool multipart = false}) {
    return Options(
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      contentType: multipart
          ? Headers.multipartFormDataContentType
          : Headers.jsonContentType,
    );
  }

  static Future<Map<String, dynamic>> store({
    required String token,
    required int bookId,
    required String institutionName,
    required String responsibleName,
    required String whatsappNumber,
    required String address,
    required String city,
    required String province,
    required String institutionType,
    required int requestedQuantity,
    int? peopleCount,
    String? reason,
    File? institutionPhoto,
    required bool isConfirmed,
  }) async {
    final formData = FormData.fromMap({
      'book_id': bookId.toString(),
      'institution_name': institutionName,
      'responsible_name': responsibleName,
      'whatsapp_number': whatsappNumber,
      'address': address,
      'city': city,
      'province': province,
      'institution_type': institutionType,
      'requested_quantity': requestedQuantity.toString(),
      'is_confirmed': isConfirmed ? '1' : '0',
      if (peopleCount != null) 'people_count': peopleCount.toString(),
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      if (institutionPhoto != null)
        'institution_photo': await MultipartFile.fromFile(
          institutionPhoto.path,
        ),
    });

    return ApiHelper.dioPostMultipart(
      dio: _dio,
      path: '/book-recipients',
      formData: formData,
      options: _authOptions(token, multipart: true),
    );
  }

  static Future<Map<String, dynamic>> show({
    required String token,
    required int id,
  }) async {
    return ApiHelper.dioGet(
      dio: _dio,
      path: '/book-recipients/$id',
      options: _authOptions(token),
    );
  }

  static Future<List<BookRecipientModel>> myApplications({
    required String token,
  }) async {
    final result = await ApiHelper.dioGet(
      dio: _dio,
      path: '/book-recipients/my',
      options: _authOptions(token),
    );

    final rawData = result['data'];

    if (rawData is List) {
      return rawData
          .map(
            (item) =>
                BookRecipientModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (rawData is Map && rawData['data'] is List) {
      return (rawData['data'] as List)
          .map(
            (item) =>
                BookRecipientModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }
}
