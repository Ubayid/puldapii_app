import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:puldapii/utils/helper/api_helper.dart';

class QuranMushafPageImage {
  final String name;
  final Uint8List bytes;
  final bool isSvg;

  const QuranMushafPageImage({
    required this.name,
    required this.bytes,
    required this.isSvg,
  });
}

class QuranMushafImageService {
  final Dio _dio;

  QuranMushafImageService(this._dio);

  Future<List<QuranMushafPageImage>> getMushafPageImages({
    required int mushafId,
    required String imagesUrl,
  }) async {
    debugPrint('Download mushaf ZIP: $imagesUrl');

    final data = await ApiHelper.dioGetBytes(
      dio: _dio,
      path: imagesUrl,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        headers: {'Accept': 'application/zip,application/octet-stream,*/*'},
      ),
    );

    debugPrint('ZIP bytes: ${data.length}');

    final archive = ZipDecoder().decodeBytes(data);

    debugPrint('ZIP item count: ${archive.length}');

    final images = <QuranMushafPageImage>[];

    for (final item in archive) {
      debugPrint('ZIP item: ${item.name} | isFile: ${item.isFile}');

      if (!item.isFile) continue;

      final filename = item.name.split('/').last;
      final lowerName = filename.toLowerCase();

      final isSvg = lowerName.endsWith('.svg');
      final isPng = lowerName.endsWith('.png');

      if (!isSvg && !isPng) continue;

      final content = item.content;

      // ignore: unnecessary_type_check
      final bytes = content is Uint8List
          ? content
          : Uint8List.fromList(content as List<int>);

      images.add(
        QuranMushafPageImage(name: filename, bytes: bytes, isSvg: isSvg),
      );
    }

    images.sort((a, b) {
      final aNumber = _extractNumber(a.name);
      final bNumber = _extractNumber(b.name);

      return aNumber.compareTo(bNumber);
    });

    debugPrint('Extracted mushaf images: ${images.length}');

    if (images.isEmpty) {
      throw const ApiFailure(
        'ZIP berhasil dibaca tapi tidak ada file SVG/PNG.',
      );
    }

    return images;
  }

  int _extractNumber(String filename) {
    final match = RegExp(r'\d+').firstMatch(filename);

    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }
}
