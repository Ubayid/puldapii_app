class Paginated<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  final String? nextPageUrl;
  final String? prevPageUrl;

  Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic> itemJson) parseItem,
  }) {
    final rawItems = (json['data'] as List?) ?? [];

    return Paginated<T>(
      items: rawItems
          .map((e) => parseItem((e as Map).cast<String, dynamic>()))
          .toList(),
      currentPage: _toInt(json['current_page']) ?? 1,
      lastPage: _toInt(json['last_page']) ?? 1,
      perPage: _toInt(json['per_page']) ?? rawItems.length,
      total: _toInt(json['total']) ?? rawItems.length,
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
