import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/book_taawun_bloc/book_taawun_bloc.dart';
import 'package:puldapii/models/book_taawun_model.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_taawun_detail_page.dart';
import 'package:puldapii/utils/services/home/book_taawun_service.dart';

class TaawunSection extends StatefulWidget {
  const TaawunSection({
    super.key,
    required this.refreshKey,
    required this.page,
    required this.perPage,
    required this.onTotalPageChanged,
    required this.onShowMessage,
    this.onSeeAllTap,
  });

  final int refreshKey;
  final int page;
  final int perPage;
  final ValueChanged<int> onTotalPageChanged;
  final ValueChanged<String> onShowMessage;
  final VoidCallback? onSeeAllTap;

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color accentColor = Color(0xFF12A99C);

  @override
  State<TaawunSection> createState() => _TaawunSectionState();
}

class _TaawunSectionState extends State<TaawunSection> {
  late Future<List<BookTaawunModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTaawuns();
  }

  @override
  void didUpdateWidget(covariant TaawunSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      _future = _loadTaawuns();
    }
  }

  Future<List<BookTaawunModel>> _loadTaawuns() async {
    final response = await BookTaawunService().getTaawuns(
      page: 1,
      perPage: 1000,
    );

    final pagination = BookTaawunPaginationModel.fromJson(response);

    return pagination.data;
  }

  void _reload() {
    setState(() {
      _future = _loadTaawuns();
    });
  }

  void _openDetail(BookTaawunModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BookTaawunBloc(service: BookTaawunService()),
          child: BookTaawunDetailPage(item: item),
        ),
      ),
    );
  }

  void _notifyTotalPageChanged(int totalPage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onTotalPageChanged(totalPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Riwayat Taawun',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: TaawunSection.primaryColor,
                ),
              ),
            ),
            if (widget.onSeeAllTap != null)
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: widget.onSeeAllTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: TaawunSection.accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: TaawunSection.accentColor,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        FutureBuilder<List<BookTaawunModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _TaawunLoadingView();
            }

            if (snapshot.hasError) {
              return _TaawunErrorView(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }

            final allTaawuns = snapshot.data ?? [];

            if (allTaawuns.isEmpty) {
              _notifyTotalPageChanged(1);
              return const _TaawunEmptyView();
            }

            final totalPage = (allTaawuns.length / widget.perPage).ceil();
            _notifyTotalPageChanged(totalPage);

            final currentPage = widget.page.clamp(1, totalPage).toInt();
            final startIndex = (currentPage - 1) * widget.perPage;
            final endIndex = (startIndex + widget.perPage)
                .clamp(0, allTaawuns.length)
                .toInt();

            final visibleTaawuns = allTaawuns.sublist(startIndex, endIndex);

            return Column(
              children: visibleTaawuns.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TaawunCard(
                    item: item,
                    onTap: () => _openDetail(item),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TaawunCard extends StatelessWidget {
  const _TaawunCard({required this.item, required this.onTap});

  final BookTaawunModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = item.book;

    final title = book?.title.trim().isNotEmpty == true
        ? book!.title
        : 'Buku Taawun';

    final donorName = item.isAnonymous
        ? 'Hamba Allah'
        : _safeText(item.donorName);

    final coverUrl = book?.coverImageUrl.trim() ?? '';
    final category = book?.category?.name.trim().isNotEmpty == true
        ? book!.category!.name
        : '-';

    final date = _formatDate(item.createdAt);
    final hasProof = item.paymentProofUrl.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(title: title, coverUrl: coverUrl),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                              color: TaawunSection.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusChip(status: item.status),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: TaawunSection.accentColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            donorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: TaawunSection.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _MiniInfo(
                          icon: Icons.receipt_long_outlined,
                          text: _safeText(item.invoiceNumber),
                        ),
                        _MiniInfo(
                          icon: Icons.calendar_month_outlined,
                          text: date,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(height: 1, color: const Color(0xFFECEFF0)),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatRupiah(item.amount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: TaawunSection.primaryColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        _ProofChip(hasProof: hasProof),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          size: 14,
                          color: Color(0xFF6D7476),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Kategori: $category',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF3E4D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.title, required this.coverUrl});

  final String title;
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFF2F7468),
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _DefaultBookCover(title: title);
              },
            )
          : _DefaultBookCover(title: title),
    );
  }
}

class _DefaultBookCover extends StatelessWidget {
  const _DefaultBookCover({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.16),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(7),
              ),
            ),
          ),
        ),
        Positioned(
          right: -13,
          bottom: -7,
          child: Icon(
            Icons.volunteer_activism_outlined,
            size: 62,
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.8,
                height: 1.08,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6D7476)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF3E4D4F),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final String label;
    final Color color;
    final IconData icon;

    if (normalized == 'approved' ||
        normalized == 'disetujui' ||
        normalized == 'diterima') {
      label = 'Disetujui';
      color = TaawunSection.accentColor;
      icon = Icons.check_circle_rounded;
    } else if (normalized == 'rejected' || normalized == 'ditolak') {
      label = 'Ditolak';
      color = Colors.redAccent;
      icon = Icons.cancel_rounded;
    } else if (normalized == 'cancelled' || normalized == 'dibatalkan') {
      label = 'Dibatalkan';
      color = Colors.redAccent;
      icon = Icons.block_rounded;
    } else if (normalized == 'process' ||
        normalized == 'processing' ||
        normalized == 'diproses') {
      label = 'Diproses';
      color = Colors.orange;
      icon = Icons.timelapse_rounded;
    } else {
      label = 'Menunggu';
      color = Colors.blueGrey;
      icon = Icons.hourglass_bottom_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofChip extends StatelessWidget {
  const _ProofChip({required this.hasProof});

  final bool hasProof;

  @override
  Widget build(BuildContext context) {
    final color = hasProof ? TaawunSection.accentColor : Colors.blueGrey;
    final icon = hasProof
        ? Icons.upload_file_rounded
        : Icons.hourglass_empty_rounded;
    final label = hasProof ? 'Ada Bukti' : 'Belum Upload';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaawunLoadingView extends StatelessWidget {
  const _TaawunLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: TaawunSection.primaryColor),
      ),
    );
  }
}

class _TaawunEmptyView extends StatelessWidget {
  const _TaawunEmptyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            color: TaawunSection.primaryColor,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada taawun',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: TaawunSection.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaawunErrorView extends StatelessWidget {
  const _TaawunErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message.replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF3E4D4F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: TaawunSection.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

String _safeText(String? value) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) return '-';

  return text;
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}

String _formatRupiah(int value) {
  return 'Rp ${_formatNumber(value)}';
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Tanggal tidak tersedia';

  final local = value.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();

  return '$day/$month/$year';
}
