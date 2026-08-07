import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  final String message;

  const ApiFailure(this.message);

  @override
  String toString() => message;
}

class ApiHelper {
  static Future<Map<String, dynamic>> dioGet({
    required Dio dio,
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw const ApiFailure('Data dari server tidak valid.');
    } on DioException catch (e) {
      throw ApiFailure(_handleDioError(e));
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  static String _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet atau server tidak dapat dijangkau.';
    }

    if (e.type == DioExceptionType.cancel) {
      return 'Request dibatalkan.';
    }

    if (e.type == DioExceptionType.badCertificate) {
      return 'Koneksi ke server tidak aman.';
    }

    if (statusCode == 401) {
      return 'Sesi login sudah berakhir. Silakan login kembali.';
    }

    if (statusCode == 403) {
      return 'Anda tidak memiliki akses.';
    }

    if (statusCode == 404) {
      return 'Data tidak ditemukan.';
    }

    if (statusCode == 422) {
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'Data yang dikirim belum sesuai.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }

    if (data is Map && data['message'] != null) {
      final message = data['message'].toString();

      if (message.trim().isNotEmpty && message.length <= 120) {
        return message;
      }
    }

    return 'Gagal mengambil data. Silakan coba lagi.';
  }

  static Future<List<dynamic>> dioGetList({
    required Dio dio,
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      final data = response.data;

      if (data is List) {
        return data;
      }

      throw const ApiFailure('Data dari server tidak valid.');
    } on DioException catch (e) {
      throw ApiFailure(_handleDioError(e));
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  static Future<Map<String, dynamic>> dioPost({
    required Dio dio,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }

      throw const ApiFailure('Data dari server tidak valid.');
    } on DioException catch (e) {
      throw ApiFailure(_handleDioError(e));
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  static Future<Map<String, dynamic>> dioPostMultipart({
    required Dio dio,
    required String path,
    required FormData formData,
    Options? options,
  }) async {
    try {
      final response = await dio.post(path, data: formData, options: options);

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }

      throw const ApiFailure('Data dari server tidak valid.');
    } on DioException catch (e) {
      throw ApiFailure(_handleDioError(e));
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  static Future<Map<String, dynamic>> dioDelete({
    required Dio dio,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final responseData = response.data;

      if (responseData == null) {
        return <String, dynamic>{};
      }

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }

      throw const ApiFailure('Data dari server tidak valid.');
    } on DioException catch (e) {
      throw ApiFailure(_handleDioError(e));
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  static Future<Uint8List> dioGetBytes({
    required Dio dio,
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestOptions = (options ?? Options()).copyWith(
        responseType: ResponseType.bytes,
      );

      final response = await dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
      );

      final data = response.data;

      if (data == null || data.isEmpty) {
        throw const ApiFailure('File kosong atau gagal didownload.');
      }

      if (data is Uint8List) {
        return data;
      }

      return Uint8List.fromList(data);
    } on DioException catch (e) {
      throw ApiFailure(_handleDioError(e));
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure('Terjadi kesalahan. Silakan coba lagi.');
    }
  }
}
