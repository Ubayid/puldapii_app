import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:puldapii/config/bloc/consultation_bloc/consultation_bloc.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_answer_page.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_form.dart';
import 'package:puldapii/pages/home/pages/layanan/consult/consult_list_page.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';

class ConsultUstadzPage extends StatefulWidget {
  const ConsultUstadzPage({super.key});

  @override
  State<ConsultUstadzPage> createState() => _ConsultUstadzPageState();
}

class _ConsultUstadzPageState extends State<ConsultUstadzPage> {
  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const int _perPage = 7;

  int _selectedTab = 0;
  int _historyPage = 1;
  int _incomingPage = 1;

  bool _showPager = false;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  void _togglePagerIfHasData(bool hasData) {
    if (!hasData) return;

    setState(() {
      _showPager = !_showPager;
    });
  }

  void _handleScrollDirection({
    required bool hasData,
    required UserScrollNotification notification,
  }) {
    if (!hasData) return;

    if (notification.metrics.axis != Axis.vertical) return;

    if (notification.direction == ScrollDirection.reverse) {
      _setShowPager(true);
    } else if (notification.direction == ScrollDirection.forward) {
      _setShowPager(false);
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<ConsultationBloc>().add(
      const ConsultationIncomingStarted(page: 1, perPage: _perPage),
    );
  }

  void _openDetailKonsultasi(Map<String, dynamic> konsultasi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultAnswerPage(konsultasi: konsultasi),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _onPagerPageChanged(int page) {
    _setShowPager(false);

    if (_selectedTab == 0) {
      if (page < 1 || page == _historyPage) return;

      setState(() {
        _historyPage = page;
      });

      context.read<ConsultationBloc>().add(
        ConsultationHistoryPageChanged(page, perPage: _perPage),
      );
    } else {
      if (page < 1 || page == _incomingPage) return;

      setState(() {
        _incomingPage = page;
      });

      context.read<ConsultationBloc>().add(
        ConsultationIncomingPageChanged(page, perPage: _perPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F4),

        floatingActionButton: _selectedTab == 0
            ? FloatingActionButton(
                heroTag: 'consult_form_fab',
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConsultForm()),
                  );
                },
              )
            : null,

        body: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  onNotifTap: () {
                    // TODO: arahkan ke halaman notifikasi kalau sudah ada
                  },
                  onChatTap: () {
                    // TODO: arahkan ke halaman chat kalau sudah ada
                  },
                ),

                Expanded(
                  child: GradientPage(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(229, 230, 234, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TabBar(
                              onTap: (index) {
                                setState(() {
                                  _selectedTab = index;
                                  _showPager = false;
                                });
                              },
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorPadding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              splashBorderRadius: BorderRadius.circular(16),
                              indicator: BoxDecoration(
                                color: const Color.fromRGBO(90, 178, 173, 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: const Color.fromRGBO(
                                80,
                                83,
                                88,
                                1,
                              ),
                              labelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              tabs: const [
                                Tab(text: 'Pengajuan'),
                                Tab(text: 'Menjawab'),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              BlocBuilder<ConsultationBloc, ConsultationState>(
                                builder: (context, state) {
                                  final hasData =
                                      state.myConsultations.isNotEmpty;

                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _togglePagerIfHasData(hasData);
                                    },
                                    child:
                                        NotificationListener<
                                          UserScrollNotification
                                        >(
                                          onNotification: (notification) {
                                            _handleScrollDirection(
                                              hasData: hasData,
                                              notification: notification,
                                            );

                                            return false;
                                          },
                                          child: const ConsultListPage(),
                                        ),
                                  );
                                },
                              ),

                              BlocConsumer<ConsultationBloc, ConsultationState>(
                                listenWhen: (previous, current) {
                                  return previous.status != current.status;
                                },
                                listener: (context, state) {
                                  if (state.status ==
                                      ConsultationStatus.answerSuccess) {
                                    _showSnackBar(
                                      state.message ??
                                          'Jawaban berhasil dikirim',
                                    );
                                    return;
                                  }

                                  if (state.status ==
                                          ConsultationStatus.failure &&
                                      state.message != null) {
                                    _showSnackBar(
                                      state.message!,
                                      isError: true,
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  final answerItems =
                                      state.incomingConsultations;

                                  if (state.status ==
                                          ConsultationStatus.incomingLoading &&
                                      answerItems.isEmpty) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    );
                                  }

                                  if (state.status ==
                                          ConsultationStatus.failure &&
                                      state.incomingConsultations.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 42,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              state.message ??
                                                  'Gagal memuat konsultasi masuk',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1B1B1B),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                context
                                                    .read<ConsultationBloc>()
                                                    .add(
                                                      const ConsultationIncomingStarted(),
                                                    );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text(
                                                'Coba Lagi',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  final hasData = answerItems.isNotEmpty;

                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _togglePagerIfHasData(hasData);
                                    },
                                    child:
                                        NotificationListener<
                                          UserScrollNotification
                                        >(
                                          onNotification: (notification) {
                                            _handleScrollDirection(
                                              hasData: hasData,
                                              notification: notification,
                                            );

                                            return false;
                                          },
                                          child: _AnswerConsultationTab(
                                            konsultasiMasuk: answerItems,
                                            totalBelumDijawab:
                                                state.incomingTotalBelumDijawab,
                                            totalSudahDijawab:
                                                state.incomingTotalSudahDijawab,
                                            onTap: _openDetailKonsultasi,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            BlocBuilder<ConsultationBloc, ConsultationState>(
              builder: (context, state) {
                final bool isPengajuanTab = _selectedTab == 0;

                final bool hasData = isPengajuanTab
                    ? state.myConsultations.isNotEmpty
                    : state.incomingConsultations.isNotEmpty;

                final bool isLoading =
                    state.status == ConsultationStatus.incomingLoading;

                final int activePage = isPengajuanTab
                    ? _historyPage
                    : _incomingPage;

                final bool activeHasNextPage = isPengajuanTab
                    ? state.myConsultations.length >= _perPage
                    : state.hasNextPage;

                return FloatingPager(
                  showPager: hasData && _showPager,
                  page: activePage,
                  isLoading: isLoading,
                  hasNextPage: hasData && activeHasNextPage,
                  onPageChanged: _onPagerPageChanged,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerConsultationTab extends StatelessWidget {
  final List<Map<String, dynamic>> konsultasiMasuk;
  final int totalBelumDijawab;
  final int totalSudahDijawab;
  final ValueChanged<Map<String, dynamic>> onTap;

  const _AnswerConsultationTab({
    required this.konsultasiMasuk,
    required this.totalBelumDijawab,
    required this.totalSudahDijawab,
    required this.onTap,
  });

  bool _isSudahDijawab(Map<String, dynamic> item) {
    final statusRaw = item['status_raw']?.toString().toLowerCase().trim();
    final status = item['status']?.toString().toLowerCase().trim();

    return statusRaw == 'answered' ||
        status == 'answered' ||
        status == 'sudah dijawab';
  }

  @override
  Widget build(BuildContext context) {
    final sortedKonsultasi = [...konsultasiMasuk];

    sortedKonsultasi.sort((a, b) {
      final aSudahDijawab = _isSudahDijawab(a);
      final bSudahDijawab = _isSudahDijawab(b);

      if (aSudahDijawab == bSudahDijawab) return 0;

      // Belum dijawab selalu di atas
      return aSudahDijawab ? 1 : -1;
    });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'Belum',
                  value: totalBelumDijawab.toString(),
                  icon: Icons.schedule_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatCard(
                  title: 'Selesai',
                  value: totalSudahDijawab.toString(),
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (sortedKonsultasi.isEmpty)
            const _EmptyConsultationCard()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedKonsultasi.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final konsultasi = sortedKonsultasi[index];

                return _SimpleConsultationCard(
                  konsultasi: konsultasi,
                  onTap: () => onTap(konsultasi),
                );
              },
            ),

          const SizedBox(height: 24),
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

class _SimpleConsultationCard extends StatelessWidget {
  final Map<String, dynamic> konsultasi;
  final VoidCallback onTap;

  const _SimpleConsultationCard({
    required this.konsultasi,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final String judul = konsultasi['judul']?.toString() ?? '-';
    final String nama = konsultasi['nama']?.toString() ?? '-';
    final String kategori = konsultasi['kategori']?.toString() ?? '-';
    final String tanggal = _formatTanggal(konsultasi['tanggal']);
    final String status = konsultasi['status']?.toString() ?? '-';

    final bool sudahDijawab = status == 'Sudah Dijawab';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
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
                          '$nama • $kategori',
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
              ],
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: sudahDijawab ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
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

class _EmptyConsultationCard extends StatelessWidget {
  const _EmptyConsultationCard();

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
              Icons.inbox_outlined,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada konsultasi masuk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Konsultasi dari jamaah akan muncul di halaman ini.',
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
