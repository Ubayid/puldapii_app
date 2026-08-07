class DakwahTagOption {
  final int id;
  final String name;
  final String slug;
  final int dakwahsCount;

  DakwahTagOption({
    required this.id,
    required this.name,
    required this.slug,
    required this.dakwahsCount,
  });

  factory DakwahTagOption.fromJson(Map<String, dynamic> json) {
    return DakwahTagOption(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      dakwahsCount: (json['dakwahs_count'] as num?)?.toInt() ?? 0,
    );
  }
}
