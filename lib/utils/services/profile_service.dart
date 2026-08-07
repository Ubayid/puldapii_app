import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:puldapii/utils/helper/api_helper.dart';

class ProfileService {
  // static const String baseUrl = 'https://layanan.puldapii.or.id/api';

  final Dio _dio;

  ProfileService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            ),
          );

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');
  }

  Future<Options> _authOptions({bool isMultipart = false}) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw const ApiFailure('Token tidak ditemukan, silakan login ulang.');
    }

    return Options(
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      contentType: isMultipart ? null : Headers.jsonContentType,
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();

    debugPrint('PROFILE TOKEN: $token');

    if (token == null || token.isEmpty) {
      throw const ApiFailure('Token tidak ditemukan, silakan login ulang.');
    }

    final body = await ApiHelper.dioGet(
      dio: _dio,
      path: '/profile',
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

    debugPrint('GET PROFILE RESPONSE: $body');

    return body;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,

    List<int>? profilePhotoBytes,
    String? profilePhotoFileName,
    bool removeProfilePhoto = false,

    bool isUstadz = false,
    String? title,
    String? gender,
    String? birthPlace,
    String? birthDate,
    String? address,
    String? city,
    String? mainTheme,
    String? languages,
    String? mosqueReference,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null && name.trim().isNotEmpty) {
      data['name'] = name.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      data['email'] = email.trim();
    }

    if (phone != null && phone.trim().isNotEmpty) {
      data['phone'] = phone.trim();
    }

    if (isUstadz) {
      if (title != null && title.trim().isNotEmpty) {
        data['title'] = title.trim();
      }

      if (gender != null && gender.trim().isNotEmpty) {
        data['gender'] = gender.trim();
      }

      if (birthPlace != null && birthPlace.trim().isNotEmpty) {
        data['birth_place'] = birthPlace.trim();
      }

      if (birthDate != null && birthDate.trim().isNotEmpty) {
        data['birth_date'] = birthDate.trim();
      }

      if (address != null && address.trim().isNotEmpty) {
        data['address'] = address.trim();
      }

      if (city != null && city.trim().isNotEmpty) {
        data['city'] = city.trim();
      }

      if (mainTheme != null && mainTheme.trim().isNotEmpty) {
        data['main_theme'] = mainTheme.trim();
      }

      if (languages != null && languages.trim().isNotEmpty) {
        data['languages'] = languages.trim();
      }

      if (mosqueReference != null && mosqueReference.trim().isNotEmpty) {
        data['mosque_reference'] = mosqueReference.trim();
      }

      data['remove_image'] = removeProfilePhoto ? '1' : '0';
    } else {
      data['remove_profile_photo'] = removeProfilePhoto ? '1' : '0';
    }

    if (profilePhotoBytes != null && profilePhotoBytes.isNotEmpty) {
      final fileName = _safeImageFileName(profilePhotoFileName);

      data[isUstadz ? 'image' : 'profile_photo'] = MultipartFile.fromBytes(
        profilePhotoBytes,
        filename: fileName,
        contentType: _getImageContentType(fileName),
      );
    }

    final formData = FormData.fromMap(data);

    final body = await ApiHelper.dioPostMultipart(
      dio: _dio,
      path: '/profile',
      formData: formData,
      options: await _authOptions(isMultipart: true),
    );

    debugPrint('UPDATE PROFILE RESPONSE: $body');

    return body;
  }

  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    final body = await ApiHelper.dioDelete(
      dio: _dio,
      path: '/profile',
      data: {'password': password},
      options: await _authOptions(),
    );

    return body;
  }

  String _safeImageFileName(String? fileName) {
    final name = fileName?.toLowerCase().trim();

    if (name == null || name.isEmpty) {
      return 'profile_photo.jpg';
    }

    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      return name;
    }

    return 'profile_photo.jpg';
  }

  MediaType _getImageContentType(String fileName) {
    final lower = fileName.toLowerCase();

    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }

    return MediaType('image', 'jpeg');
  }
}
