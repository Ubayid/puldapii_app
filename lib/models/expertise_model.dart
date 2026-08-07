class ExpertisePivot {
  final int? ustadzId;
  final int? expertiseId;

  ExpertisePivot({this.ustadzId, this.expertiseId});

  factory ExpertisePivot.fromJson(Map<String, dynamic> json) {
    return ExpertisePivot(
      ustadzId: json['ustadz_id'] is int
          ? json['ustadz_id']
          : int.tryParse('${json['ustadz_id']}'),
      expertiseId: json['expertise_id'] is int
          ? json['expertise_id']
          : int.tryParse('${json['expertise_id']}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'ustadz_id': ustadzId,
    'expertise_id': expertiseId,
  };
}

class ExpertiseModel {
  final int id;
  final String? name;
  final ExpertisePivot? pivot;

  ExpertiseModel({required this.id, this.name, this.pivot});

  factory ExpertiseModel.fromJson(Map<String, dynamic> json) {
    return ExpertiseModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString(),
      pivot: json['pivot'] is Map<String, dynamic>
          ? ExpertisePivot.fromJson(json['pivot'])
          : json['pivot'] is Map
          ? ExpertisePivot.fromJson(Map<String, dynamic>.from(json['pivot']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'pivot': pivot?.toJson(),
  };
}
