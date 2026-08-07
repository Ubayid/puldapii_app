class HadistModel {
  final int id;
  final String kitab;
  final String arab;
  final String terjemah;

  HadistModel({
    required this.id,
    required this.kitab,
    required this.arab,
    required this.terjemah,
  });

  factory HadistModel.fromJson(Map<String, dynamic> json) {
    return HadistModel(
      id: _toInt(json['id']),
      kitab: (json['kitab'] ?? '').toString(),
      arab: (json['arab'] ?? '').toString(),
      terjemah: (json['terjemah'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
