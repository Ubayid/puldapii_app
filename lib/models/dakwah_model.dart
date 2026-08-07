class UstadzMini {
  final String code;
  final String name;
  final String image; // path asli dari DB (opsional dipakai)
  final String imageUrl; // URL siap tampil

  UstadzMini({
    required this.code,
    required this.name,
    required this.image,
    required this.imageUrl,
  });

  factory UstadzMini.fromJson(Map<String, dynamic> json) {
    return UstadzMini(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

class DakwahTagPivot {
  final int dakwahId;
  final int tagId;

  DakwahTagPivot({required this.dakwahId, required this.tagId});

  factory DakwahTagPivot.fromJson(Map<String, dynamic> json) {
    return DakwahTagPivot(
      dakwahId: (json['dakwah_id'] as num?)?.toInt() ?? 0,
      tagId: (json['tag_id'] as num?)?.toInt() ?? 0,
    );
  }
}

class DakwahTagModel {
  final int id;
  final String name;
  final String slug;
  final DakwahTagPivot? pivot; // opsional

  DakwahTagModel({
    required this.id,
    required this.name,
    required this.slug,
    this.pivot,
  });

  factory DakwahTagModel.fromJson(Map<String, dynamic> json) {
    return DakwahTagModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      pivot: json['pivot'] == null
          ? null
          : DakwahTagPivot.fromJson(json['pivot'] as Map<String, dynamic>),
    );
  }
}

class DakwahModel {
  final int id;
  final String ustadzCode;
  final String title;
  final String description;
  final String date;
  final String islamicDate;
  final String time;
  final String location;

  final double? locationLat;
  final double? locationLng;
  final String? placeId;
  final String? locationAddress;

  final UstadzMini? ustadz;

  // NEW: tags
  final List<DakwahTagModel> tags;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  DakwahModel({
    required this.id,
    required this.ustadzCode,
    required this.title,
    required this.description,
    required this.date,
    required this.islamicDate,
    required this.time,
    required this.location,
    this.locationLat,
    this.locationLng,
    this.placeId,
    this.locationAddress,
    required this.ustadz,

    // NEW
    this.tags = const [],

    this.createdAt,
    this.updatedAt,
  });

  factory DakwahModel.fromJson(Map<String, dynamic> json) {
    final latStr = (json['location_lat'] ?? '').toString().trim();
    final lngStr = (json['location_lng'] ?? '').toString().trim();

    final tagsJson = (json['tags'] as List?) ?? const [];
    final tags = tagsJson
        .whereType<Map<String, dynamic>>()
        .map((e) => DakwahTagModel.fromJson(e))
        .toList();

    return DakwahModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ustadzCode: (json['ustadz_code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      islamicDate: (json['islamic_date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),

      locationLat: latStr.isEmpty ? null : double.tryParse(latStr),
      locationLng: lngStr.isEmpty ? null : double.tryParse(lngStr),
      placeId: (json['place_id'] ?? '').toString().trim().isEmpty
          ? null
          : (json['place_id'] ?? '').toString(),
      locationAddress:
          (json['location_address'] ?? '').toString().trim().isEmpty
          ? null
          : (json['location_address'] ?? '').toString(),

      ustadz: json['ustadz'] == null
          ? null
          : UstadzMini.fromJson(json['ustadz'] as Map<String, dynamic>),

      // NEW
      tags: tags,

      createdAt:
          json['created_at'] != null &&
              json['created_at'].toString().trim().isNotEmpty
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt:
          json['updated_at'] != null &&
              json['updated_at'].toString().trim().isNotEmpty
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
