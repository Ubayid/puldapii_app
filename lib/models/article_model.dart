class ArticleModel {
  final int id;
  final DateTime date;
  final String title;
  final String? excerptHtml;
  final String? contentHtml;
  final String categoryName;
  final String imageUrl;

  ArticleModel({
    required this.id,
    required this.date,
    required this.title,
    this.excerptHtml,
    this.contentHtml,
    required this.categoryName,
    required this.imageUrl,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final title =
        (json['title'] as Map<String, dynamic>?)?['rendered']?.toString() ?? '';
    final excerpt = (json['excerpt'] as Map<String, dynamic>?)?['rendered']
        ?.toString();
    final content = (json['content'] as Map<String, dynamic>?)?['rendered']
        ?.toString();

    final date =
        DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now();

    String imageUrl = '';
    final fm = json['_embedded']?['wp:featuredmedia'];
    if (fm is List && fm.isNotEmpty) {
      final media = fm.first;
      if (media is Map<String, dynamic>) {
        final sizes = media['media_details']?['sizes'];
        final medium = sizes?['medium']?['source_url'];
        final large = sizes?['large']?['source_url'];

        imageUrl = (large ?? medium ?? media['source_url'] ?? '').toString();
      }
    }

    String categoryName = '';
    final wpTerm = json['_embedded']?['wp:term'];
    if (wpTerm is List) {
      for (final group in wpTerm) {
        if (group is List) {
          for (final term in group) {
            if (term is Map<String, dynamic> &&
                term['taxonomy'] == 'category') {
              categoryName = (term['name'] ?? '').toString();
              break;
            }
          }
        }
        if (categoryName.isNotEmpty) break;
      }
    }

    return ArticleModel(
      id: (json['id'] as num).toInt(),
      date: date,
      title: title,
      excerptHtml: excerpt,
      contentHtml: content,
      categoryName: categoryName,
      imageUrl: imageUrl,
    );
  }
}

class ArticleCategory {
  final int id;
  final String name;

  ArticleCategory({required this.id, required this.name});

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }
}
