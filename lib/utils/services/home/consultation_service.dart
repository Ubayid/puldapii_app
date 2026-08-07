import 'package:dio/dio.dart';
import 'package:puldapii/models/consultation_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class ConsultationService {
  final Dio _dio;

  ConsultationService(this._dio);

  Future<Map<String, dynamic>> createConsultation({
    required int expertiseId,
    required String title,
    required String question,
  }) async {
    final body = await ApiHelper.dioPost(
      dio: _dio,
      path: '/consultations',
      data: {'expertise_id': expertiseId, 'title': title, 'question': question},
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal mengirim konsultasi',
      );
    }

    return body;
  }

  Future<ConsultationPageResult> getUstadzConsultations({
    int page = 1,
    int perPage = 7,
  }) async {
    final bodyMap = await ApiHelper.dioGet(
      dio: _dio,
      path: '/ustadz-consultations',
      queryParameters: {'page': page, 'per_page': perPage},
    );

    if (bodyMap['success'] != true) {
      throw ApiFailure(
        bodyMap['message']?.toString() ?? 'Gagal memuat konsultasi ustadz',
      );
    }

    return ConsultationPageResult.fromJson(
      bodyMap,
      fallbackPage: page,
      itemMapper: _mapConsultation,
    );
  }

  Future<Map<String, dynamic>> getUstadzConsultationDetail({
    required int consultationId,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: _dio,
      path: '/ustadz-consultations/$consultationId',
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal memuat detail konsultasi',
      );
    }

    final data = body['data'];

    if (data is Map) {
      return _mapConsultation(data);
    }

    throw const ApiFailure('Data konsultasi tidak valid.');
  }

  Future<Map<String, dynamic>> answerConsultation({
    required int consultationId,
    required String answer,
  }) async {
    final body = await ApiHelper.dioPost(
      dio: _dio,
      path: '/ustadz-consultations/$consultationId/answer',
      data: {'answer': answer},
    );

    if (body['success'] == false) {
      throw ApiFailure(body['message']?.toString() ?? 'Gagal mengirim jawaban');
    }

    return body;
  }

  Future<List<Map<String, dynamic>>> getMyConsultations({
    int page = 1,
    int perPage = 7,
  }) async {
    final body = await ApiHelper.dioGet(
      dio: _dio,
      path: '/my-consultations',
      queryParameters: {'page': page, 'per_page': perPage},
    );

    if (body['success'] == false) {
      throw ApiFailure(
        body['message']?.toString() ?? 'Gagal memuat konsultasi saya',
      );
    }

    final data = body['data'];

    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  Map<String, dynamic> _mapConsultation(dynamic item) {
    final map = Map<String, dynamic>.from(item as Map);

    final user = map['user'];
    final ustadz = map['ustadz'];
    final expertise = map['expertise'];

    final answer = map['answer'];
    final status = map['status']?.toString().toLowerCase();

    return {
      'id': map['id'],
      'user_id': map['user_id'],
      'ustadz_id': map['ustadz_id'],
      'expertise_id': map['expertise_id'],

      'nama': user is Map
          ? user['name']?.toString() ?? '-'
          : map['nama']?.toString() ?? '-',

      'phone': user is Map
          ? user['phone']?.toString() ?? '-'
          : map['phone']?.toString() ?? '-',

      'email': user is Map
          ? user['email']?.toString() ?? '-'
          : map['email']?.toString() ?? '-',

      'ustadz': ustadz is Map ? ustadz['name']?.toString() ?? '-' : '-',

      'ustadz_title': ustadz is Map ? ustadz['title']?.toString() ?? '-' : '-',

      'ustadz_image': ustadz is Map ? ustadz['image']?.toString() : null,

      'kategori': expertise is Map
          ? expertise['name']?.toString() ?? '-'
          : map['kategori']?.toString() ?? '-',

      'judul': map['title']?.toString() ?? '-',
      'pesan': map['question']?.toString() ?? '-',

      'jawaban': answer?.toString() ?? '',

      'status_raw': map['status']?.toString() ?? '',
      'status': status == 'answered' || answer != null
          ? 'Sudah Dijawab'
          : 'Belum Dijawab',

      'tanggal': map['created_at']?.toString() ?? '-',
      'answered_at': map['answered_at']?.toString(),
      'updated_at': map['updated_at']?.toString(),
    };
  }
}
