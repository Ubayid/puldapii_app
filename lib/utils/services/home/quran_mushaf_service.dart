import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class QuranMushafService {
  final Dio dio;

  QuranMushafService(this.dio);

  Future<List<QuranMushafModel>> getMushafs() async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/quran/mushafs',
    );

    final data = body['data'];

    if (data is! List) {
      throw const ApiFailure('Format data mushaf tidak valid.');
    }

    return data.map<QuranMushafModel>((item) {
      return QuranMushafModel.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }

  Future<QuranMushafModel> getMushafDetail(int mushafId) async {
    final body = await ApiHelper.dioGet(
      dio: dio,
      path: '${ApiConfig.apiBaseUrl}/quran/mushafs/$mushafId',
    );

    final data = body['data'];

    if (data is! Map) {
      throw const ApiFailure('Format detail mushaf tidak valid.');
    }

    return QuranMushafModel.fromJson(Map<String, dynamic>.from(data));
  }

  Map<int, List<QuranAyahModel>> groupAyahsByPage(List<QuranAyahModel> ayahs) {
    final Map<int, List<QuranAyahModel>> grouped = {};

    for (final ayah in ayahs) {
      grouped.putIfAbsent(ayah.pageNumber, () => []);
      grouped[ayah.pageNumber]!.add(ayah);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return {for (final key in sortedKeys) key: grouped[key]!};
  }
}
