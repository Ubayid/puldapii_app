class PosterTemplateModel {
  final int id;
  final String title;
  final String imageUrl;
  final String status;
  final List<PosterCategoryModel> categories;

  final bool isBanner;
  final bool isFeatured;

  PosterTemplateModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.categories,
    required this.isBanner,
    required this.isFeatured,
  });

  factory PosterTemplateModel.fromJson(Map<String, dynamic> json) {
    return PosterTemplateModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? '',
      categories: (json['categories'] as List? ?? [])
          .map((item) => PosterCategoryModel.fromJson(item))
          .toList(),
      isBanner: _toBool(json['is_banner']),
      isFeatured: _toBool(json['is_featured']),
    );
  }
}

bool _toBool(dynamic value) {
  if (value == true) return true;
  if (value == 1) return true;
  if (value == '1') return true;
  if (value == 'true') return true;
  return false;
}

class PosterCategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String? status;

  PosterCategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.status,
  });

  factory PosterCategoryModel.fromJson(Map<String, dynamic> json) {
    return PosterCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      status: json['status'],
    );
  }
}
