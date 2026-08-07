class DzikirPpModel {
  final int idDzikirPp;
  final String user;
  final String slug;
  final String title;
  final String arabic;
  final String arti;
  final String penjelasan;
  final String waktu;

  DzikirPpModel({
    required this.idDzikirPp,
    required this.user,
    required this.slug,
    required this.title,
    required this.arabic,
    required this.arti,
    required this.penjelasan,
    required this.waktu,
  });

  factory DzikirPpModel.fromJson(Map<String, dynamic> json) {
    return DzikirPpModel(
      idDzikirPp: json['id_dzikir_pp'] ?? 0,
      user: json['user'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      arti: json['arti'] ?? '',
      penjelasan: json['penjelasan'] ?? '',
      waktu: json['waktu'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dzikir_pp': idDzikirPp,
      'user': user,
      'slug': slug,
      'title': title,
      'arabic': arabic,
      'arti': arti,
      'penjelasan': penjelasan,
      'waktu': waktu,
    };
  }
}
