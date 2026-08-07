class ConsultationModel {
  final int id;
  final String title;
  final String question;
  final String answer;
  final String status;
  final String createdAt;
  final String ustadzName;
  final String category;

  const ConsultationModel({
    required this.id,
    required this.title,
    required this.question,
    required this.answer,
    required this.status,
    required this.createdAt,
    required this.ustadzName,
    required this.category,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    final ustadz = json['ustadz'];
    final expertise = json['expertise'];

    String ustadzName = '';

    if (json['ustadz_name'] != null) {
      ustadzName = json['ustadz_name'].toString();
    } else if (ustadz is Map) {
      final ustadzMap = Map<String, dynamic>.from(ustadz);

      if (ustadzMap['name'] != null) {
        ustadzName = ustadzMap['name'].toString();
      } else if (ustadzMap['user'] is Map) {
        final user = Map<String, dynamic>.from(ustadzMap['user']);
        ustadzName = user['name']?.toString() ?? '';
      }
    } else if (ustadz != null) {
      ustadzName = ustadz.toString();
    }

    String category = '';

    if (json['expertise_name'] != null) {
      category = json['expertise_name'].toString();
    } else if (expertise is Map) {
      final expertiseMap = Map<String, dynamic>.from(expertise);
      category = expertiseMap['name']?.toString() ?? '';
    } else if (json['kategori'] != null) {
      category = json['kategori'].toString();
    }

    return ConsultationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title:
          json['title']?.toString() ??
          json['judul']?.toString() ??
          'Konsultasi',
      question:
          json['question']?.toString() ?? json['pertanyaan']?.toString() ?? '',
      answer: json['answer']?.toString() ?? json['jawaban']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Menunggu',
      createdAt:
          json['created_at']?.toString() ?? json['tanggal']?.toString() ?? '',
      ustadzName: ustadzName,
      category: category,
    );
  }
}

class ConsultationPageResult {
  final List<Map<String, dynamic>> items;
  final int totalBelumDijawab;
  final int totalSudahDijawab;
  final int currentPage;
  final int lastPage;

  const ConsultationPageResult({
    required this.items,
    required this.totalBelumDijawab,
    required this.totalSudahDijawab,
    required this.currentPage,
    required this.lastPage,
  });

  factory ConsultationPageResult.fromJson(
    Map<String, dynamic> json, {
    required Map<String, dynamic> Function(dynamic item) itemMapper,
    required int fallbackPage,
  }) {
    final pagination = json['data'];

    if (pagination is! Map) {
      return ConsultationPageResult(
        items: const [],
        totalBelumDijawab: 0,
        totalSudahDijawab: 0,
        currentPage: fallbackPage,
        lastPage: fallbackPage,
      );
    }

    final paginationMap = Map<String, dynamic>.from(pagination);

    final rawList = paginationMap['data'];

    final items = rawList is List
        ? rawList.map<Map<String, dynamic>>(itemMapper).toList()
        : <Map<String, dynamic>>[];

    final summary = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : paginationMap['summary'] is Map
        ? Map<String, dynamic>.from(paginationMap['summary'] as Map)
        : <String, dynamic>{};

    return ConsultationPageResult(
      items: items,
      totalBelumDijawab:
          int.tryParse(summary['belum_dijawab']?.toString() ?? '') ?? 0,
      totalSudahDijawab:
          int.tryParse(summary['sudah_dijawab']?.toString() ?? '') ?? 0,
      currentPage:
          int.tryParse(paginationMap['current_page']?.toString() ?? '') ??
          fallbackPage,
      lastPage:
          int.tryParse(paginationMap['last_page']?.toString() ?? '') ??
          fallbackPage,
    );
  }
}
