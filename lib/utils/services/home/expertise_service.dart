import 'package:dio/dio.dart';
import 'package:puldapii/config/api_response.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class ExpertiseService {
  final Dio dio;

  ExpertiseService(this.dio);

  Future<List<Map<String, dynamic>>> getExpertises() async {
    final body = await ApiHelper.dioGet(dio: dio, path: '/expertises');

    final result = ApiResponse<List<Map<String, dynamic>>>.fromJson(
      body,
      parseData: (dataJson) => (dataJson as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );

    return result.data;
  }
}
