class NewsModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: _parseNullableString(json['image']),
      category: json['category']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _parseNullableString(dynamic value) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class NewsPagination {
  final List<NewsModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMorePages;

  const NewsPagination({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.hasMorePages,
  });

  factory NewsPagination.fromJson(Map<String, dynamic> json) {
    final pagination = Map<String, dynamic>.from(
      json['pagination'] as Map? ?? {},
    );

    final rawData = json['data'];

    return NewsPagination(
      data: rawData is List
          ? rawData
                .whereType<Map>()
                .map(
                  (item) => NewsModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <NewsModel>[],
      currentPage: _parseInt(pagination['current_page']),
      lastPage: _parseInt(pagination['last_page']),
      perPage: _parseInt(pagination['per_page']),
      total: _parseInt(pagination['total']),
      from: _parseNullableInt(pagination['from']),
      to: _parseNullableInt(pagination['to']),
      hasMorePages: pagination['has_more_pages'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}
