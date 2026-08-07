import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/config/api_response.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/models/ustadz_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class UstadzService {
  final Dio dio;

  UstadzService({Dio? dio})
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

  Future<Paginated<UstadzModel>> getUstadzList({
    int perPage = 10,
    int page = 1,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '/ustadz',
      queryParameters: {'per_page': perPage, 'page': page},
    );

    final wrapped = ApiResponse<Paginated<UstadzModel>>.fromJson(
      body,
      parseData: (dataJson) => Paginated<UstadzModel>.fromJson(
        Map<String, dynamic>.from(dataJson as Map),
        parseItem: (itemJson) => UstadzModel.fromJson(itemJson),
      ),
    );

    return wrapped.data;
  }

  Future<UstadzModel> getUstadzDetail(int id) async {
    final body = await ApiHelper.dioGet(dio: dio, path: '/ustadz/$id');

    final wrapped = ApiResponse<UstadzModel>.fromJson(
      body,
      parseData: (dataJson) =>
          UstadzModel.fromJson(Map<String, dynamic>.from(dataJson as Map)),
    );

    return wrapped.data;
  }

  Future<UstadzModel> getUstadzDetailByCode(String code) async {
    final body = await ApiHelper.dioGet(dio: dio, path: '/ustadz/code/$code');

    final wrapped = ApiResponse<UstadzModel>.fromJson(
      body,
      parseData: (dataJson) =>
          UstadzModel.fromJson(Map<String, dynamic>.from(dataJson as Map)),
    );

    return wrapped.data;
  }
}
