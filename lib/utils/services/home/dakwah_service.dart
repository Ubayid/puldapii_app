import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/dakwah_model.dart';
import 'package:puldapii/models/dakwah_tags_option_model.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class DakwahService {
  final Dio dio;

  DakwahService({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

  Future<Paginated<DakwahModel>> fetchDakwah({
    int perPage = 10,
    int page = 1,
    Set<int>? tagIds,
  }) async {
    final queryParameters = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };

    if (tagIds != null && tagIds.isNotEmpty) {
      queryParameters['tag_ids'] = tagIds.join(',');
    }

    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '/dakwah',
      queryParameters: queryParameters,
    );

    if (body['success'] == false) {
      throw ApiFailure(body['message']?.toString() ?? 'Gagal load dakwah');
    }

    final data = body['data'];

    if (data is Map) {
      return Paginated<DakwahModel>.fromJson(
        Map<String, dynamic>.from(data),
        parseItem: (itemJson) => DakwahModel.fromJson(itemJson),
      );
    }

    throw const ApiFailure('Data dakwah tidak valid.');
  }

  Future<List<DakwahTagOption>> fetchTagOptions({
    int perPage = 50,
    int page = 1,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '/tags',
      queryParameters: {'per_page': perPage, 'page': page},
    );

    if (body['success'] == false) {
      throw ApiFailure(body['message']?.toString() ?? 'Gagal load tags');
    }

    final data = body['data'];

    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;

      return list
          .map(
            (e) =>
                DakwahTagOption.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }

    if (data is List) {
      return data
          .map(
            (e) =>
                DakwahTagOption.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }

    return [];
  }
}
