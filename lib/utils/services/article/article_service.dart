import 'package:dio/dio.dart';
import 'package:puldapii/models/article_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class ArticleService {
  static const String baseUrl = 'https://portal.puldapii.or.id/wp-json/wp/v2';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      responseType: ResponseType.json,
    ),
  );

  Future<List<ArticleModel>> fetchPostList({
    List<int>? categoryIds,
    int perPage = 10,
    int page = 1,
    String? search,
  }) async {
    final data = await ApiHelper.dioGetList(
      dio: _dio,
      path: '/posts',
      queryParameters: {
        if (categoryIds != null && categoryIds.isNotEmpty)
          'categories': categoryIds.join(','),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'per_page': perPage,
        'page': page,
        '_embed': 1,
      },
    );

    return data
        .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ArticleModel> fetchPostDetail(int id) async {
    final data = await ApiHelper.dioGet(
      dio: _dio,
      path: '/posts/$id',
      queryParameters: {'_embed': 1},
    );

    return ArticleModel.fromJson(data);
  }

  Future<List<ArticleCategory>> fetchCategories() async {
    final data = await ApiHelper.dioGetList(
      dio: _dio,
      path: '/categories',
      queryParameters: {'per_page': 100, 'hide_empty': true},
    );

    return data
        .map((e) => ArticleCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
