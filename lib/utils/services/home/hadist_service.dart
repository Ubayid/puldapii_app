import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/config/api_response.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/models/hadist_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class HadistService {
  final Dio dio;

  HadistService(this.dio);

  Future<List<String>> getBooks() async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/hadist/books',
    );

    final result = ApiResponse<List<String>>.fromJson(
      body,
      parseData: (dataJson) => List<String>.from(dataJson ?? []),
    );

    return result.data;
  }

  Future<Paginated<HadistModel>> getHadist({
    required String book,
    int page = 1,
    int perPage = 20,
    String query = '',
  }) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/hadist/$book',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (query.trim().isNotEmpty) 'q': query.trim(),
      },
    );

    final result = ApiResponse<Paginated<HadistModel>>.fromJson(
      body,
      parseData: (dataJson) => Paginated<HadistModel>.fromJson(
        Map<String, dynamic>.from(dataJson as Map),
        parseItem: (itemJson) => HadistModel.fromJson(itemJson),
      ),
    );

    return result.data;
  }

  Future<HadistModel> getHadistDetail({
    required String book,
    required int id,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/hadist/$book/$id',
    );

    final data = body['data'];

    if (data is Map) {
      return HadistModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ApiFailure('Format detail hadist tidak valid.');
  }
}
