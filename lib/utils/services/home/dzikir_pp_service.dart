import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/config/api_response.dart';
import 'package:puldapii/models/dzikir_pp_model.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class DzikirPpService {
  final Dio dio;

  DzikirPpService(this.dio);

  Future<List<DzikirPpModel>> getDzikirList() async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/dzikir-pp',
    );

    final data = body['data'];

    if (data is List) {
      return data.map((item) {
        return DzikirPpModel.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    }

    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;

      return list.map((item) {
        return DzikirPpModel.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    }

    throw const ApiFailure('Format data dzikir tidak valid.');
  }

  Future<Paginated<DzikirPpModel>> getDzikirPaginated({
    required String waktu,
    int page = 1,
    int perPage = 1,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/dzikir-pp',
      queryParameters: {'waktu': waktu, 'page': page, 'per_page': perPage},
    );

    final result = ApiResponse<Paginated<DzikirPpModel>>.fromJson(
      body,
      parseData: (dataJson) {
        if (dataJson is! Map) {
          throw const ApiFailure('Format pagination dzikir tidak valid.');
        }

        return Paginated<DzikirPpModel>.fromJson(
          Map<String, dynamic>.from(dataJson),
          parseItem: (itemJson) => DzikirPpModel.fromJson(itemJson),
        );
      },
    );

    return result.data;
  }

  Future<DzikirPpModel> getDzikirById(int id) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/dzikir-pp/$id',
    );

    final result = ApiResponse<DzikirPpModel>.fromJson(
      body,
      parseData: (dataJson) {
        if (dataJson is! Map) {
          throw const ApiFailure('Format detail dzikir tidak valid.');
        }

        return DzikirPpModel.fromJson(Map<String, dynamic>.from(dataJson));
      },
    );

    return result.data;
  }

  Future<DzikirPpModel> getDzikirBySlug(String slug) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/dzikir-pp/slug/$slug',
    );

    final result = ApiResponse<DzikirPpModel>.fromJson(
      body,
      parseData: (dataJson) {
        if (dataJson is! Map) {
          throw const ApiFailure('Format detail dzikir tidak valid.');
        }

        return DzikirPpModel.fromJson(Map<String, dynamic>.from(dataJson));
      },
    );

    return result.data;
  }
}
