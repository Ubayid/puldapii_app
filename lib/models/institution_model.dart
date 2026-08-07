class InstitutionModel {
  final int id;
  final String? name;
  final String? slug;

  final String? logo;
  final String? logoUrl;

  final String? coverImage;
  final String? coverImageUrl;

  final String? institutionType;
  final String? sector;

  final String? province;
  final String? city;
  final String? address;

  final int? joinedYear;
  final String? description;

  final String? status;
  final String? verificationStatus;

  final String? whatsapp;
  final String? email;
  final String? website;
  final String? locationUrl;

  final bool isActive;

  final int? programsCount;
  final int? galleriesCount;

  final List<InstitutionProgramModel> programs;
  final List<InstitutionGalleryModel> galleries;

  final String? createdAt;
  final String? updatedAt;

  InstitutionModel({
    required this.id,
    this.name,
    this.slug,
    this.logo,
    this.logoUrl,
    this.coverImage,
    this.coverImageUrl,
    this.institutionType,
    this.sector,
    this.province,
    this.city,
    this.address,
    this.joinedYear,
    this.description,
    this.status,
    this.verificationStatus,
    this.whatsapp,
    this.email,
    this.website,
    this.locationUrl,
    this.isActive = false,
    this.programsCount,
    this.galleriesCount,
    this.programs = const [],
    this.galleries = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: _toInt(json['id']) ?? 0,
      name: _toString(json['name']),
      slug: _toString(json['slug']),

      logo: _toString(json['logo']),
      logoUrl: _toString(json['logo_url']),

      coverImage: _toString(json['cover_image']),
      coverImageUrl: _toString(json['cover_image_url']),

      institutionType: _toString(json['institution_type']),
      sector: _toString(json['sector']),

      province: _toString(json['province']),
      city: _toString(json['city']),
      address: _toString(json['address']),

      joinedYear: _toInt(json['joined_year']),
      description: _toString(json['description']),

      status: _toString(json['status']),
      verificationStatus: _toString(json['verification_status']),

      whatsapp: _toString(json['whatsapp']),
      email: _toString(json['email']),
      website: _toString(json['website']),
      locationUrl: _toString(json['location_url']),

      isActive: _toBool(json['is_active']),

      programsCount: _toInt(json['programs_count']),
      galleriesCount: _toInt(json['galleries_count']),

      programs: (json['programs'] as List? ?? [])
          .map(
            (e) =>
                InstitutionProgramModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),

      galleries: (json['galleries'] as List? ?? [])
          .map(
            (e) =>
                InstitutionGalleryModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),

      createdAt: _toString(json['created_at']),
      updatedAt: _toString(json['updated_at']),
    );
  }
}

class InstitutionProgramModel {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final int? sortOrder;

  InstitutionProgramModel({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.imageUrl,
    this.isActive = false,
    this.sortOrder,
  });

  factory InstitutionProgramModel.fromJson(Map<String, dynamic> json) {
    return InstitutionProgramModel(
      id: _toInt(json['id']) ?? 0,
      title: _toString(json['title']),
      description: _toString(json['description']),
      image: _toString(json['image']),
      imageUrl: _toString(json['image_url']),
      isActive: _toBool(json['is_active']),
      sortOrder: _toInt(json['sort_order']),
    );
  }
}

class InstitutionGalleryModel {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final int? sortOrder;

  InstitutionGalleryModel({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.imageUrl,
    this.isActive = false,
    this.sortOrder,
  });

  factory InstitutionGalleryModel.fromJson(Map<String, dynamic> json) {
    return InstitutionGalleryModel(
      id: _toInt(json['id']) ?? 0,
      title: _toString(json['title']),
      description: _toString(json['description']),
      image: _toString(json['image']),
      imageUrl: _toString(json['image_url']),
      isActive: _toBool(json['is_active']),
      sortOrder: _toInt(json['sort_order']),
    );
  }
}

String? _toString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value == true || value == 1 || value == '1') return true;
  if (value == 'true') return true;
  return false;
}
