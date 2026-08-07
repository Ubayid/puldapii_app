class BookTaawunPaginationModel {
  final int currentPage;
  final List<BookTaawunModel> data;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  const BookTaawunPaginationModel({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory BookTaawunPaginationModel.fromJson(Map<String, dynamic> json) {
    final pagination = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final list = pagination['data'];

    return BookTaawunPaginationModel(
      currentPage: _toInt(pagination['current_page'], fallback: 1),
      data: list is List
          ? list
                .where((item) => item is Map)
                .map(
                  (item) => BookTaawunModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : [],
      lastPage: _toInt(pagination['last_page'], fallback: 1),
      perPage: _toInt(pagination['per_page'], fallback: 10),
      total: _toInt(pagination['total']),
      from: _toNullableInt(pagination['from']),
      to: _toNullableInt(pagination['to']),
    );
  }
}

class BookTaawunModel {
  final int id;
  final int bookId;
  final int? userId;
  final String invoiceNumber;
  final int amount;

  final String donorName;
  final String donorWhatsapp;
  final String donorEmail;
  final bool isAnonymous;

  final String paymentProof;
  final String paymentProofUrl;
  final DateTime? paymentProofUploadedAt;

  final String status;
  final int? verifiedBy;
  final DateTime? verifiedAt;
  final String adminNote;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final BookTaawunBookModel? book;
  final BookTaawunUserModel? user;
  final BookTaawunUserModel? verifier;

  const BookTaawunModel({
    required this.id,
    required this.bookId,
    this.userId,
    required this.invoiceNumber,
    required this.amount,
    required this.donorName,
    required this.donorWhatsapp,
    required this.donorEmail,
    required this.isAnonymous,
    required this.paymentProof,
    required this.paymentProofUrl,
    this.paymentProofUploadedAt,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    required this.adminNote,
    this.createdAt,
    this.updatedAt,
    this.book,
    this.user,
    this.verifier,
  });

  factory BookTaawunModel.fromJson(Map<String, dynamic> json) {
    return BookTaawunModel(
      id: _toInt(json['id']),
      bookId: _toInt(json['book_id']),
      userId: _toNullableInt(json['user_id']),
      invoiceNumber: _toString(json['invoice_number']),
      amount: _toInt(json['amount']),
      donorName: _toString(json['donor_name']),
      donorWhatsapp: _toString(json['donor_whatsapp']),
      donorEmail: _toString(json['donor_email']),
      isAnonymous: _toBool(json['is_anonymous']),
      paymentProof: _toString(json['payment_proof']),
      paymentProofUrl: _toString(json['payment_proof_url']),
      paymentProofUploadedAt: _toDateTime(json['payment_proof_uploaded_at']),
      status: _toString(json['status']),
      verifiedBy: _toNullableInt(json['verified_by']),
      verifiedAt: _toDateTime(json['verified_at']),
      adminNote: _toString(json['admin_note']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      book: json['book'] is Map
          ? BookTaawunBookModel.fromJson(
              Map<String, dynamic>.from(json['book'] as Map),
            )
          : null,
      user: json['user'] is Map
          ? BookTaawunUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
      verifier: json['verifier'] is Map
          ? BookTaawunUserModel.fromJson(
              Map<String, dynamic>.from(json['verifier'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'amount': amount,
      'donor_name': donorName,
      'donor_whatsapp': donorWhatsapp,
      'donor_email': donorEmail,
      'is_anonymous': isAnonymous,
      'payment_proof': paymentProof,
      'payment_proof_url': paymentProofUrl,
      'payment_proof_uploaded_at': paymentProofUploadedAt?.toIso8601String(),
      'status': status,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'admin_note': adminNote,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'book': book?.toJson(),
      'user': user?.toJson(),
      'verifier': verifier?.toJson(),
    };
  }
}

class BookTaawunBookModel {
  final int id;
  final int? bookCategoryId;
  final String title;
  final String slug;
  final String author;
  final String coverImage;
  final int totalPages;
  final int printCost;
  final int targetQuantity;
  final int collectedQuantity;
  final String description;
  final List<String> benefits;
  final String status;
  final bool isFeatured;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BookTaawunCategoryModel? category;

  const BookTaawunBookModel({
    required this.id,
    this.bookCategoryId,
    required this.title,
    required this.slug,
    required this.author,
    required this.coverImage,
    required this.totalPages,
    required this.printCost,
    required this.targetQuantity,
    required this.collectedQuantity,
    required this.description,
    required this.benefits,
    required this.status,
    required this.isFeatured,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory BookTaawunBookModel.fromJson(Map<String, dynamic> json) {
    return BookTaawunBookModel(
      id: _toInt(json['id']),
      bookCategoryId: _toNullableInt(json['book_category_id']),
      title: _toString(json['title']),
      slug: _toString(json['slug']),
      author: _toString(json['author']),
      coverImage: _toString(json['cover_image']),
      totalPages: _toInt(json['total_pages']),
      printCost: _toInt(json['print_cost']),
      targetQuantity: _toInt(json['target_quantity']),
      collectedQuantity: _toInt(json['collected_quantity']),
      description: _toString(json['description']),
      benefits: _toStringList(json['benefits']),
      status: _toString(json['status']),
      isFeatured: _toBool(json['is_featured']),
      sortOrder: _toInt(json['sort_order']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      category: json['category'] is Map
          ? BookTaawunCategoryModel.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
    );
  }

  String get coverImageUrl {
    if (coverImage.isEmpty) return '';

    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
      return coverImage;
    }

    return 'https://layanan.puldapii.or.id/files/$coverImage';
  }

  int get progressPercent {
    if (targetQuantity <= 0) return 0;

    final value = ((collectedQuantity / targetQuantity) * 100).round();

    if (value > 100) return 100;

    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_category_id': bookCategoryId,
      'title': title,
      'slug': slug,
      'author': author,
      'cover_image': coverImage,
      'total_pages': totalPages,
      'print_cost': printCost,
      'target_quantity': targetQuantity,
      'collected_quantity': collectedQuantity,
      'description': description,
      'benefits': benefits,
      'status': status,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category?.toJson(),
    };
  }
}

class BookTaawunCategoryModel {
  final int id;
  final int? wordpressCategoryId;
  final String name;
  final String slug;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookTaawunCategoryModel({
    required this.id,
    this.wordpressCategoryId,
    required this.name,
    required this.slug,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BookTaawunCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookTaawunCategoryModel(
      id: _toInt(json['id']),
      wordpressCategoryId: _toNullableInt(json['wordpress_category_id']),
      name: _toString(json['name']),
      slug: _toString(json['slug']),
      status: _toString(json['status']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wordpress_category_id': wordpressCategoryId,
      'name': name,
      'slug': slug,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class BookTaawunUserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String profilePhoto;
  final DateTime? emailVerifiedAt;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookTaawunUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePhoto,
    this.emailVerifiedAt,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory BookTaawunUserModel.fromJson(Map<String, dynamic> json) {
    return BookTaawunUserModel(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      email: _toString(json['email']),
      phone: _toString(json['phone']),
      profilePhoto: _toString(json['profile_photo']),
      emailVerifiedAt: _toDateTime(json['email_verified_at']),
      role: _toString(json['role']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  String get profilePhotoUrl {
    if (profilePhoto.isEmpty) return '';

    if (profilePhoto.startsWith('http://') ||
        profilePhoto.startsWith('https://')) {
      return profilePhoto;
    }

    return 'https://layanan.puldapii.or.id/files/$profilePhoto';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_photo': profilePhoto,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty) return null;

  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(text);
}

String _toString(dynamic value) {
  if (value == null) return '';

  return value.toString();
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;

  final text = value?.toString().toLowerCase().trim();

  return text == '1' || text == 'true' || text == 'yes';
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return [];
}
