import 'package:puldapii/models/book_model.dart';

class BookRecipientModel {
  final int id;
  final int bookId;

  final String institutionName;
  final String responsibleName;
  final String whatsappNumber;

  final String address;
  final String city;
  final String province;

  final String institutionType;

  final int requestedQuantity;
  final int? peopleCount;

  final String? reason;
  final String? institutionPhoto;
  final String? institutionPhotoUrl;

  final bool isConfirmed;
  final String status;

  final BookModel? book;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookRecipientModel({
    required this.id,
    required this.bookId,
    required this.institutionName,
    required this.responsibleName,
    required this.whatsappNumber,
    required this.address,
    required this.city,
    required this.province,
    required this.institutionType,
    required this.requestedQuantity,
    this.peopleCount,
    this.reason,
    this.institutionPhoto,
    this.institutionPhotoUrl,
    required this.isConfirmed,
    required this.status,
    this.book,
    this.createdAt,
    this.updatedAt,
  });

  factory BookRecipientModel.fromJson(Map<String, dynamic> json) {
    return BookRecipientModel(
      id: _toInt(json['id']),
      bookId: _toInt(
        json['book_id'] ??
            json['bookId'] ??
            (json['book'] is Map<String, dynamic> ? json['book']['id'] : null),
      ),

      institutionName: json['institution_name']?.toString() ?? '',
      responsibleName: json['responsible_name']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',

      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      province: json['province']?.toString() ?? '',

      institutionType: json['institution_type']?.toString() ?? '',

      requestedQuantity: _toInt(json['requested_quantity']),
      peopleCount: json['people_count'] == null
          ? null
          : _toInt(json['people_count']),

      reason: json['reason']?.toString(),
      institutionPhoto: json['institution_photo']?.toString(),
      institutionPhotoUrl: json['institution_photo_url']?.toString(),

      isConfirmed: _toBool(json['is_confirmed']),
      status: json['status']?.toString() ?? 'pending',

      book: json['book'] is Map<String, dynamic>
          ? BookModel.fromJson(Map<String, dynamic>.from(json['book']))
          : null,

      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  String get bookTitle {
    return book?.title.toString().trim().isNotEmpty == true
        ? book!.title.toString()
        : 'Buku';
  }

  String get locationText {
    final parts = [
      city.trim(),
      province.trim(),
    ].where((item) => item.isNotEmpty).toList();

    return parts.join(', ');
  }

  String get formattedCreatedAt {
    if (createdAt == null) return '';

    final day = createdAt!.day.toString().padLeft(2, '0');
    final month = createdAt!.month.toString().padLeft(2, '0');
    final year = createdAt!.year.toString();

    return '$day/$month/$year';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'institution_name': institutionName,
      'responsible_name': responsibleName,
      'whatsapp_number': whatsappNumber,
      'address': address,
      'city': city,
      'province': province,
      'institution_type': institutionType,
      'requested_quantity': requestedQuantity,
      'people_count': peopleCount,
      'reason': reason,
      'institution_photo': institutionPhoto,
      'institution_photo_url': institutionPhotoUrl,
      'is_confirmed': isConfirmed,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      // BookModel kamu belum punya toJson(), jadi jangan dipaksa convert.
      // Kalau butuh data buku, akses langsung dari property `book`.
      'book': null,
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value.toString().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
