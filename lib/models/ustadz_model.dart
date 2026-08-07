import 'package:puldapii/models/expertise_model.dart';
import 'package:puldapii/models/ustadz_roles_model.dart';

class UstadzModel {
  final int id;
  final String? code;
  final String? name;
  final String? title;
  final String? gender;
  final String? birthPlace;
  final String? birthDate;
  final int? age;
  final String? contactNumber;
  final String? email;
  final String? address;
  final String? village;
  final String? district;
  final String? city;
  final String? mainTheme;
  final String? languages;
  final String? status;
  final int? availability;
  final String? mosqueReference;
  final String? adminNote;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final String? imageUrl;

  final List<UstadzRole> roles;
  final List<ExpertiseModel> expertises;
  final List<String> relatedVideos;

  UstadzModel({
    required this.id,
    this.code,
    this.name,
    this.title,
    this.gender,
    this.birthPlace,
    this.birthDate,
    this.age,
    this.contactNumber,
    this.email,
    this.address,
    this.village,
    this.district,
    this.city,
    this.mainTheme,
    this.languages,
    this.status,
    this.availability,
    this.mosqueReference,
    this.adminNote,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    required this.roles,
    required this.expertises,
    this.relatedVideos = const [],
  });

  factory UstadzModel.fromJson(Map<String, dynamic> json) {
    final rolesJson = (json['roles'] as List?) ?? const [];
    final expertisesJson = (json['expertises'] as List?) ?? const [];
    final rawVideos = json['related_videos'];

    List<String> parsedVideos = [];
    if (rawVideos is String && rawVideos.trim().isNotEmpty) {
      parsedVideos = [rawVideos.trim()];
    } else if (rawVideos is List) {
      parsedVideos = rawVideos
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return UstadzModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      gender: json['gender']?.toString(),
      birthPlace: json['birth_place']?.toString(),
      birthDate: json['birth_date']?.toString(),
      age: json['age'] is int ? json['age'] : int.tryParse('${json['age']}'),
      contactNumber: json['contact_number']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      village: json['village']?.toString(),
      district: json['district']?.toString(),
      city: json['city']?.toString(),
      mainTheme: json['main_theme']?.toString(),
      languages: json['languages']?.toString(),
      status: json['status']?.toString(),
      availability: json['availability'] is int
          ? json['availability']
          : int.tryParse('${json['availability']}'),
      mosqueReference: json['mosque_reference']?.toString(),
      adminNote: json['admin_note']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      imageUrl: json['image_url']?.toString(),
      roles: rolesJson
          .whereType<Map>()
          .map((e) => UstadzRole.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      expertises: expertisesJson
          .whereType<Map>()
          .map((e) => ExpertiseModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      relatedVideos: parsedVideos,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'title': title,
    'gender': gender,
    'birth_place': birthPlace,
    'birth_date': birthDate,
    'age': age,
    'contact_number': contactNumber,
    'email': email,
    'address': address,
    'village': village,
    'district': district,
    'city': city,
    'main_theme': mainTheme,
    'languages': languages,
    'status': status,
    'availability': availability,
    'mosque_reference': mosqueReference,
    'admin_note': adminNote,
    'image': image,
    'related_videos': relatedVideos,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'image_url': imageUrl,
    'roles': roles.map((e) => e.toJson()).toList(),
    'expertises': expertises.map((e) => e.toJson()).toList(),
  };

  List<String> get roleNames =>
      roles.map((r) => r.name ?? '').where((s) => s.trim().isNotEmpty).toList();

  List<String> get expertiseNames => expertises
      .map((e) => e.name ?? '')
      .where((e) => e.trim().isNotEmpty)
      .toList();
}
