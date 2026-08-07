class BookModel {
  final int id;
  final int? bookCategoryId;
  final BookCategoryModel? category;

  final String title;
  final String slug;
  final String author;

  final String coverImage;
  final String coverUrl;
  final String coverImageUrl;

  final int totalPages;
  final int printCost;
  final int targetQuantity;
  final int collectedQuantity;

  final int progress;
  final int progressPercent;

  final String status;
  final bool isFeatured;
  final int sortOrder;

  final String description;
  final List<String> benefits;
  final List<BookPreviewImageModel> previewImages;

  BookModel({
    required this.id,
    required this.bookCategoryId,
    required this.category,
    required this.title,
    required this.slug,
    required this.author,
    required this.coverImage,
    required this.coverUrl,
    required this.coverImageUrl,
    required this.totalPages,
    required this.printCost,
    required this.targetQuantity,
    required this.collectedQuantity,
    required this.progress,
    required this.progressPercent,
    required this.status,
    required this.isFeatured,
    required this.sortOrder,
    required this.description,
    required this.benefits,
    required this.previewImages,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final coverUrl = json['cover_url']?.toString() ?? '';
    final coverImageUrl = json['cover_image_url']?.toString() ?? '';

    return BookModel(
      id: _toInt(json['id']),
      bookCategoryId: json['book_category_id'] == null
          ? null
          : _toInt(json['book_category_id']),
      category: json['category'] == null
          ? null
          : BookCategoryModel.fromJson(
              Map<String, dynamic>.from(json['category']),
            ),

      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      author: json['author']?.toString() ?? '',

      coverImage: json['cover_image']?.toString() ?? '',
      coverUrl: coverUrl.isNotEmpty ? coverUrl : coverImageUrl,
      coverImageUrl: coverImageUrl.isNotEmpty ? coverImageUrl : coverUrl,

      totalPages: _toInt(json['total_pages']),
      printCost: _toInt(json['print_cost']),
      targetQuantity: _toInt(json['target_quantity']),
      collectedQuantity: _toInt(json['collected_quantity']),

      progress: _toInt(json['progress']),
      progressPercent: _toInt(json['progress_percent']),

      status: json['status']?.toString() ?? '',
      isFeatured: _toBool(json['is_featured']),
      sortOrder: _toInt(json['sort_order']),

      description: json['description']?.toString() ?? '',
      benefits: _toStringList(json['benefits']),
      previewImages: _toPreviewImages(json['preview_images']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];

    return value.map((item) => item.toString()).toList();
  }

  static List<BookPreviewImageModel> _toPreviewImages(dynamic value) {
    if (value is! List) return [];

    return value
        .map(
          (item) =>
              BookPreviewImageModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    return value.toString() == '1' || value.toString() == 'true';
  }
}

class BookPreviewImageModel {
  final int id;
  final String image;
  final String imageUrl;
  final int sortOrder;

  BookPreviewImageModel({
    required this.id,
    required this.image,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory BookPreviewImageModel.fromJson(Map<String, dynamic> json) {
    final imageUrl =
        json['image_url']?.toString() ??
        json['preview_url']?.toString() ??
        json['url']?.toString() ??
        '';

    return BookPreviewImageModel(
      id: BookModel._toInt(json['id']),
      image:
          json['image']?.toString() ??
          json['path']?.toString() ??
          json['preview_image']?.toString() ??
          '',
      imageUrl: imageUrl,
      sortOrder: BookModel._toInt(json['sort_order']),
    );
  }
}

class BookCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final int sortOrder;

  BookCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.sortOrder,
  });

  factory BookCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookCategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sortOrder: _toInt(json['sort_order']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
}
