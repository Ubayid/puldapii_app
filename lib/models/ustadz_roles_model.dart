class UstadzRole {
  final int id;
  final String? slug;
  final String? name;
  final UstadzRolePivot? pivot;

  UstadzRole({required this.id, this.slug, this.name, this.pivot});

  factory UstadzRole.fromJson(Map<String, dynamic> json) {
    return UstadzRole(
      id: (json['id']) as int,
      slug: json['slug']?.toString(),
      name: json['name']?.toString(),
      pivot: json['pivot'] is Map<String, dynamic>
          ? UstadzRolePivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'pivot': pivot?.toJson(),
  };
}

class UstadzRolePivot {
  final int? ustadzId;
  final int? ustadzRoleId;
  final int? isAvailable;
  final String? createdAt;
  final String? updatedAt;

  UstadzRolePivot({
    this.ustadzId,
    this.ustadzRoleId,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory UstadzRolePivot.fromJson(Map<String, dynamic> json) {
    return UstadzRolePivot(
      ustadzId: json['ustadz_id'] is int
          ? json['ustadz_id'] as int
          : int.tryParse('${json['ustadz_id']}'),
      ustadzRoleId: json['ustadz_role_id'] is int
          ? json['ustadz_role_id'] as int
          : int.tryParse('${json['ustadz_role_id']}'),
      isAvailable: json['is_available'] is int
          ? json['is_available'] as int
          : int.tryParse('${json['is_available']}'),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ustadz_id': ustadzId,
    'ustadz_role_id': ustadzRoleId,
    'is_available': isAvailable,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
