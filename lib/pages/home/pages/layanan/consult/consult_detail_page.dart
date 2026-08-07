import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:puldapii/utils/services/home/consultation_detail_service.dart';
import 'package:puldapii/utils/widget/background.dart';

class ConsultDetailPage extends StatefulWidget {
  final Map<String, dynamic>? konsultasi;
  final int? consultationId;

  const ConsultDetailPage({super.key, this.konsultasi, this.consultationId})
    : assert(
        konsultasi != null || consultationId != null,
        'konsultasi atau consultationId harus diisi',
      );

  @override
  State<ConsultDetailPage> createState() => _ConsultDetailPageState();
}

class _ConsultDetailPageState extends State<ConsultDetailPage> {
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  final ConsultationDetailService _service = ConsultationDetailService();

  late Future<Map<String, dynamic>> _futureConsultation;

  @override
  void initState() {
    super.initState();

    if (widget.konsultasi != null) {
      _futureConsultation = Future.value(widget.konsultasi!);
    } else {
      _futureConsultation = _service.getMyConsultationDetail(
        widget.consultationId!,
      );
    }
  }

  String _safeText(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  String _formatTanggal(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return DateFormat('dd MMMM yyyy', 'id_ID').format(date.toLocal());
  }

  String _readName(dynamic value) {
    if (value is Map) {
      return _safeText(value['name'] ?? value['nama'], fallback: '');
    }

    return _safeText(value, fallback: '');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureConsultation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F8F4),
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF7F8F4),
              elevation: 0,
              iconTheme: const IconThemeData(color: primaryColor),
              title: const Text(
                'Detail Konsultasi',
                style: TextStyle(
                  color: Color(0xFF1B1B1B),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          );
        }

        final konsultasi = snapshot.data!;

        final String judul = _safeText(
          konsultasi['judul'] ?? konsultasi['title'],
          fallback: 'Konsultasi',
        );

        final String kategori = _safeText(
          konsultasi['kategori'] ??
              (konsultasi['expertise'] is Map
                  ? konsultasi['expertise']['name']
                  : null),
          fallback: '-',
        );

        final String ustadz = _safeText(
          konsultasi['ustadz_name'] ?? _readName(konsultasi['ustadz']),
          fallback: 'Belum dipilih ustadz',
        );

        final String tanggal = _formatTanggal(
          konsultasi['tanggal'] ?? konsultasi['created_at'],
        );

        final String status = _safeText(
          konsultasi['status'],
          fallback: 'pending',
        );

        final String pesan = _safeText(
          konsultasi['pesan'] ??
              konsultasi['question'] ??
              konsultasi['pertanyaan'],
          fallback: '-',
        );

        final String jawaban = _safeText(
          konsultasi['jawaban'] ?? konsultasi['answer'],
          fallback: 'Belum ada jawaban.',
        );

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F8F4),
            elevation: 0,
            iconTheme: const IconThemeData(color: primaryColor),
            title: const Text(
              'Detail Konsultasi',
              style: TextStyle(
                color: Color(0xFF1B1B1B),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          body: GradientPage(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(status: status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _WhiteCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Ustadz',
                          value: ustadz,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.category_outlined,
                          label: 'Kategori',
                          value: kategori,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal',
                          value: tanggal,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Isi Pertanyaan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pesan,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jawaban Ustadz',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            jawaban,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final String statusLower = status.toLowerCase().trim();

    final bool answered = statusLower == 'answered';

    final Color color = answered ? Colors.green : Colors.red;
    final String label = answered ? 'Terjawab' : 'Menunggu';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
