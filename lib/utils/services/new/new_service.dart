import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/new_model.dart';

class NewsService {
  final Dio dio;

  NewsService({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            ),
          );

  Future<NewsPagination> getNews({
    int page = 1,
    int perPage = 10,
    String? q,
    String? category,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      final search = q?.trim();

      if (search != null && search.isNotEmpty) {
        queryParameters['q'] = search;
      }

      if (category != null && category.isNotEmpty && category != 'Semua') {
        queryParameters['category'] = category;
      }

      final response = await dio.get('/news', queryParameters: queryParameters);

      if (response.data is! Map) {
        throw Exception('Format response berita tidak valid.');
      }

      return NewsPagination.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (error) {
      throw Exception(_getErrorMessage(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<NewsModel> getNewsDetail(int id) async {
    try {
      final response = await dio.get('/news/$id');

      if (response.data is! Map) {
        throw Exception('Format response detail berita tidak valid.');
      }

      final responseData = Map<String, dynamic>.from(response.data);

      if (responseData['data'] is! Map) {
        throw Exception('Data detail berita tidak ditemukan.');
      }

      return NewsModel.fromJson(
        Map<String, dynamic>.from(responseData['data']),
      );
    } on DioException catch (error) {
      throw Exception(_getErrorMessage(error));
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  String _getErrorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);

      if (map['message'] != null) {
        return map['message'].toString();
      }

      final errors = map['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }

        return firstError.toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi ke server terlalu lama.';

      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';

      default:
        return 'Gagal mengambil data berita.';
    }
  }
}
