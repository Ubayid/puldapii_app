import 'dart:io';

import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/poster_template_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class PosterTemplateService {
  final Dio dio;

  PosterTemplateService({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            ),
          );

  Future<List<PosterTemplateModel>> fetchPosterTemplates({
    String? search,
    int? posterCategoryId,
    int perPage = 10,
    int page = 1,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '/poster-templates',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (posterCategoryId != null) 'poster_category_id': posterCategoryId,
        'per_page': perPage,
        'page': page,
      },
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal mengambil template poster',
      );
    }

    final data = body['data'];

    if (data is List) {
      return data.map((item) {
        return PosterTemplateModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    }

    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;

      return list.map((item) {
        return PosterTemplateModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    }

    return [];
  }

  Future<PosterTemplateModel> fetchPosterTemplateDetail(int id) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '/poster-templates/$id',
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal mengambil detail template poster',
      );
    }

    final data = body['data'];

    if (data is Map) {
      return PosterTemplateModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ApiFailure('Data detail template poster tidak valid.');
  }

  Future<PosterTemplateModel> createPosterTemplate({
    required String token,
    required String title,
    required File image,
    List<int> categoryIds = const [],
    String status = 'published',
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('title', title));
    formData.fields.add(MapEntry('status', status));

    for (final categoryId in categoryIds) {
      formData.fields.add(MapEntry('category_ids[]', categoryId.toString()));
    }

    formData.files.add(
      MapEntry('image', await MultipartFile.fromFile(image.path)),
    );

    final body = await ApiHelper.dioPostMultipart(
      dio: dio,
      path: '/poster-templates',
      formData: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal menambahkan template poster',
      );
    }

    final data = body['data'];

    if (data is Map) {
      return PosterTemplateModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ApiFailure('Data template poster tidak valid.');
  }

  Future<PosterTemplateModel> updatePosterTemplate({
    required String token,
    required int id,
    required String title,
    File? image,
    List<int> categoryIds = const [],
    String status = 'published',
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('title', title));
    formData.fields.add(MapEntry('status', status));

    for (final categoryId in categoryIds) {
      formData.fields.add(MapEntry('category_ids[]', categoryId.toString()));
    }

    if (image != null) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(image.path)),
      );
    }

    final body = await ApiHelper.dioPostMultipart(
      dio: dio,
      path: '/poster-templates/$id',
      formData: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal memperbarui template poster',
      );
    }

    final data = body['data'];

    if (data is Map) {
      return PosterTemplateModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ApiFailure('Data template poster tidak valid.');
  }

  Future<void> deletePosterTemplate({
    required String token,
    required int id,
  }) async {
    final body = await ApiHelper.dioDelete(
      dio: dio,
      path: '/poster-templates/$id',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal menghapus template poster',
      );
    }
  }

  Future<List<PosterCategoryModel>> fetchPosterCategories() async {
    final body = await ApiHelper.dioGet(dio: dio, path: '/poster-categories');

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal mengambil kategori poster',
      );
    }

    final data = body['data'];

    if (data is List) {
      return data.map((item) {
        return PosterCategoryModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    }

    return [];
  }
}
