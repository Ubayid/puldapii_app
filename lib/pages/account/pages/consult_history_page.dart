import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:puldapii/config/bloc/consultation_bloc/consultation_bloc.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_detail_page.dart';
import 'package:puldapii/utils/widget/background.dart';

class ConsultHistoryPage extends StatefulWidget {
  const ConsultHistoryPage({super.key});

  @override
  State<ConsultHistoryPage> createState() => _ConsultHistoryPageState();
}

class _ConsultHistoryPageState extends State<ConsultHistoryPage> {
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  void initState() {
    super.initState();
    context.read<ConsultationBloc>().add(const ConsultationHistoryStarted());
  }

  Future<void> _refresh() async {
    context.read<ConsultationBloc>().add(const ConsultationHistoryRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F4),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        title: const Text(
          'Riwayat Konsultasi',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<ConsultationBloc, ConsultationState>(
        builder: (context, state) {
          final isLoading = state.status == ConsultationStatus.incomingLoading;
          final consultations = state.myConsultations;

          if (isLoading && consultations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          return _MyConsultationHistoryList(consultations: consultations);
        },
      ),
    );
  }
}

class _MyConsultationHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> consultations;

  const _MyConsultationHistoryList({required this.consultations});

  @override
  Widget build(BuildContext context) {
    final belumDijawab = consultations.where((item) {
      final statusRaw = item['status_raw']?.toString().toLowerCase();
      final status = item['status']?.toString().toLowerCase();

      return statusRaw != 'answered' &&
          status != 'sudah dijawab' &&
          status != 'answered';
    }).length;

    final sudahDijawab = consultations.where((item) {
      final statusRaw = item['status_raw']?.toString().toLowerCase();
      final status = item['status']?.toString().toLowerCase();

      return statusRaw == 'answered' ||
          status == 'sudah dijawab' ||
          status == 'answered';
    }).length;

    return GradientPage(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: 'Belum',
                    value: belumDijawab.toString(),
                    icon: Icons.schedule_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Selesai',
                    value: sudahDijawab.toString(),
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (consultations.isEmpty)
              const _EmptyMyConsultationCard()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: consultations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final konsultasi = consultations[index];

                  return _MyConsultationCard(konsultasi: konsultasi);
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MyConsultationCard extends StatelessWidget {
  final Map<String, dynamic> konsultasi;

  const _MyConsultationCard({required this.konsultasi});

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase().trim()) {
      case 'hadits':
        return Icons.menu_book_outlined;
      case 'fiqih':
        return Icons.balance_outlined;
      case 'tafsir':
        return Icons.auto_stories_outlined;
      case 'aqidah':
        return Icons.shield_outlined;
      case 'muamalah':
        return Icons.handshake_outlined;
      case 'akhlak':
        return Icons.favorite_border_outlined;
      case 'pendidikan':
        return Icons.school_outlined;
      case 'hukum':
        return Icons.gavel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatTanggal(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return DateFormat('dd MMMM yyyy', 'id_ID').format(date.toLocal());
  }

  String _safeText(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  String _readName(dynamic value) {
    if (value is Map) {
      return _safeText(value['name'] ?? value['nama'], fallback: '');
    }

    return _safeText(value, fallback: '');
  }

  @override
  Widget build(BuildContext context) {
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

    final String status = _safeText(konsultasi['status'], fallback: 'Menunggu');

    _safeText(konsultasi['status_raw'], fallback: status).toLowerCase();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConsultDetailPage(konsultasi: konsultasi),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryColor.withOpacity(0.12),
                  child: Icon(_getCategoryIcon(kategori), color: primaryColor),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$ustadz • $kategori',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tanggal,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
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

class _EmptyMyConsultationCard extends StatelessWidget {
  const _EmptyMyConsultationCard();

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada konsultasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Konsultasi yang kamu ajukan akan muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
