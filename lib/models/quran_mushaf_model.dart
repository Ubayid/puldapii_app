class QuranMushafModel {
  final int id;
  final String name;
  final String? qiraat;
  final String? rawi;
  final String? country;
  final String? description;
  final String? fontFile;
  final String? imageUrl;
  final String? bismillah;
  final String? images;
  final String? imagesPng;
  final List<QuranSurahModel> surahs;

  const QuranMushafModel({
    required this.id,
    required this.name,
    this.qiraat,
    this.rawi,
    this.country,
    this.description,
    this.fontFile,
    this.imageUrl,
    this.bismillah,
    this.images,
    this.imagesPng,
    this.surahs = const [],
  });

  factory QuranMushafModel.fromJson(Map<String, dynamic> json) {
    final rawiJson = json['rawi'] is Map<String, dynamic>
        ? json['rawi'] as Map<String, dynamic>
        : null;

    final qiraaJson = rawiJson?['qiraa'] is Map<String, dynamic>
        ? rawiJson!['qiraa'] as Map<String, dynamic>
        : null;

    return QuranMushafModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['mushaf_name'] ?? '').toString(),
      qiraat: qiraaJson?['name']?.toString(),
      rawi: rawiJson?['name']?.toString(),
      country: json['country']?.toString(),
      description: json['description']?.toString(),
      fontFile: json['font_file']?.toString(),
      imageUrl: json['image']?.toString(),
      bismillah: json['bismillah']?.toString(),
      images: json['images']?.toString(),
      imagesPng: json['images_png']?.toString(),
      surahs: (json['surahs'] is List)
          ? (json['surahs'] as List)
                .map(
                  (e) => QuranSurahModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }

  QuranMushafModel copyWith({
    int? id,
    String? name,
    String? qiraat,
    String? rawi,
    String? country,
    String? description,
    String? fontFile,
    String? imageUrl,
    String? bismillah,
    String? images,
    String? imagesPng,
    List<QuranSurahModel>? surahs,
  }) {
    return QuranMushafModel(
      id: id ?? this.id,
      name: name ?? this.name,
      qiraat: qiraat ?? this.qiraat,
      rawi: rawi ?? this.rawi,
      country: country ?? this.country,
      description: description ?? this.description,
      fontFile: fontFile ?? this.fontFile,
      imageUrl: imageUrl ?? this.imageUrl,
      bismillah: bismillah ?? this.bismillah,
      images: images ?? this.images,
      imagesPng: imagesPng ?? this.imagesPng,
      surahs: surahs ?? this.surahs,
    );
  }
}

class QuranSurahModel {
  final int id;
  final int surahNumber;
  final String name;
  final String? englishName;
  final String? revelationType;
  final List<QuranAyahModel> ayahs;

  const QuranSurahModel({
    required this.id,
    required this.surahNumber,
    required this.name,
    this.englishName,
    this.revelationType,
    this.ayahs = const [],
  });

  factory QuranSurahModel.fromJson(Map<String, dynamic> json) {
    return QuranSurahModel(
      id: _toInt(json['id']),
      surahNumber: _toInt(json['number'] ?? json['surah_number'] ?? json['id']),
      name: (json['name'] ?? json['surah_name'] ?? '').toString(),
      englishName: json['english_name']?.toString(),
      revelationType: json['revelation_type']?.toString(),
      ayahs: (json['ayahs'] is List)
          ? (json['ayahs'] as List)
                .map(
                  (e) => QuranAyahModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class QuranAyahModel {
  final int id;
  final int number;
  final int surah;
  final int pageNumber;
  final int juz;
  final int hizb;
  final int ruku;
  final int manzil;
  final String text;
  final String? marker;
  final List<int> numberInHafs;

  const QuranAyahModel({
    required this.id,
    required this.number,
    required this.surah,
    required this.pageNumber,
    required this.juz,
    required this.hizb,
    required this.ruku,
    required this.manzil,
    required this.text,
    this.marker,
    this.numberInHafs = const [],
  });

  factory QuranAyahModel.fromJson(Map<String, dynamic> json) {
    return QuranAyahModel(
      id: _toInt(json['id']),
      number: _toInt(json['number']),
      surah: _toInt(json['surah']),
      pageNumber: _toInt(json['page_number']),
      juz: _toInt(json['juz']),
      hizb: _toInt(json['hizb']),
      ruku: _toInt(json['ruku']),
      manzil: _toInt(json['manzil']),
      text: (json['text'] ?? '').toString().replaceAll('\uFEFF', '').trim(),
      marker: json['marker']?.toString(),
      numberInHafs:
          (json['number_in_hafs'] as List?)?.map((e) => _toInt(e)).toList() ??
          const [],
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}
