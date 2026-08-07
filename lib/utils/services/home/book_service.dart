import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class BookService {
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

  Future<List<BookCategoryModel>> getBookCategories() async {
    final body = await ApiHelper.dioGet(dio: _dio, path: '/book-categories');

    final data = body['data'];

    if (data is List) {
      return data
          .map(
            (item) =>
                BookCategoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }

  Future<List<BookModel>> getBooks({
    String? search,
    int? bookCategoryId,
    String? categorySlug,
    int page = 1,
    int perPage = 10,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: _dio,
      path: '/books',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (bookCategoryId != null) 'book_category_id': bookCategoryId,
        if (categorySlug != null && categorySlug.trim().isNotEmpty)
          'category_slug': categorySlug.trim(),
      },
    );

    return _parseBookList(body['data']);
  }

  Future<List<BookModel>> getFeaturedBooks() async {
    final body = await ApiHelper.dioGet(dio: _dio, path: '/books/featured');

    return _parseBookList(body['data']);
  }

  Future<BookModel> getBookDetail(String idOrSlug) async {
    final body = await ApiHelper.dioGet(dio: _dio, path: '/books/$idOrSlug');

    final data = body['data'];

    if (data is Map) {
      return BookModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ApiFailure('Format detail buku tidak valid.');
  }

  List<BookModel> _parseBookList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => BookModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => BookModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }
}
