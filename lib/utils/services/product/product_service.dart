import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/product_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class ProductService {
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

  Future<ProductModel> getDetail(int id) async {
    final decoded = await ApiHelper.dioGet(dio: _dio, path: '/products/$id');

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw const ApiFailure('Data produk tidak valid.');
    }

    return ProductModel.fromJson(data);
  }

  Future<List<ProductModel>> getList({int perPage = 10, int page = 1}) async {
    final decoded = await ApiHelper.dioGet(
      dio: _dio,
      path: '/products',
      queryParameters: {'per_page': perPage, 'page': page},
    );

    final paginator = decoded['data'];

    if (paginator is! Map<String, dynamic>) {
      throw const ApiFailure('Data produk tidak valid.');
    }

    final items = paginator['data'];

    if (items is! List) {
      throw const ApiFailure('List produk tidak valid.');
    }

    return items
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
