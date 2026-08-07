import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/book_bloc/book_bloc.dart';
import 'package:puldapii/config/bloc/book_recipient_bloc/book_recipient_bloc.dart';
import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/models/book_recipient_model.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_recipient_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmissionSection extends StatefulWidget {
  const SubmissionSection({
    super.key,
    required this.refreshKey,
    required this.page,
    required this.perPage,
    required this.onTotalPageChanged,
    required this.onShowMessage,
  });

  final int refreshKey;
  final int page;
  final int perPage;
  final ValueChanged<int> onTotalPageChanged;
  final ValueChanged<String> onShowMessage;

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);
  static const Color accentColor = Color(0xFF12A99C);

  @override
  State<SubmissionSection> createState() => _SubmissionSectionState();
}

class _SubmissionSectionState extends State<SubmissionSection> {
  String? _token;
  bool _isCheckingToken = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    setState(() {
      _token = token;
      _isCheckingToken = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingToken) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(),
          SizedBox(height: 10),
          _PengajuanLoadingView(),
        ],
      );
    }

    if (_token == null || _token!.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(),
          SizedBox(height: 10),
          _PengajuanLoginView(),
        ],
      );
    }

    return BlocProvider(
      key: ValueKey('pengajuan-saya-${widget.refreshKey}-$_token'),
      create: (_) =>
          BookRecipientBloc()..add(FetchMyBookRecipients(token: _token!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(),

          const SizedBox(height: 10),

          BlocBuilder<BookRecipientBloc, BookRecipientState>(
            builder: (context, state) {
              if (state is BookRecipientLoading) {
                return const _PengajuanLoadingView();
              }

              if (state is BookRecipientError) {
                return _PengajuanErrorView(
                  message: state.message,
                  onRetry: () {
                    context.read<BookRecipientBloc>().add(
                      FetchMyBookRecipients(token: _token!),
                    );
                  },
                );
              }

              if (state is BookRecipientListLoaded) {
                final items = state.data;

                if (items.isEmpty) {
                  widget.onTotalPageChanged(1);
                  return const _PengajuanEmptyView();
                }

                final totalPage = (items.length / widget.perPage).ceil();
                widget.onTotalPageChanged(totalPage);

                final currentPage = widget.page.clamp(1, totalPage).toInt();
                final startIndex = (currentPage - 1) * widget.perPage;
                final endIndex = (startIndex + widget.perPage)
                    .clamp(0, items.length)
                    .toInt();
                final visibleItems = items.sublist(startIndex, endIndex);

                return BlocBuilder<BookBloc, BookState>(
                  builder: (context, bookState) {
                    final catalogBooks = bookState is BooksLoaded
                        ? bookState.books
                        : <BookModel>[];

                    return Column(
                      children: visibleItems.map((item) {
                        final catalogBook = _findBookById(
                          catalogBooks,
                          item.bookId,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PengajuanCard(
                            item: item,
                            catalogBook: catalogBook,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookRecipientDetailPage(
                                    item: item,
                                    catalogBook: catalogBook,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Pengajuan Saya',
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        color: SubmissionSection.primaryColor,
      ),
    );
  }
}

class _PengajuanCard extends StatelessWidget {
  const _PengajuanCard({
    required this.item,
    this.catalogBook,
    required this.onTap,
  });

  final BookRecipientModel item;
  final BookModel? catalogBook;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final book = _bestBook(item: item, catalogBook: catalogBook);

    final title = book?.title.trim().isNotEmpty == true
        ? book!.title
        : item.bookTitle;

    final institutionName = item.institutionName.isNotEmpty
        ? item.institutionName
        : 'Lembaga penerima';

    final institutionType = item.institutionType.isNotEmpty
        ? item.institutionType
        : '-';

    final location = item.locationText;
    final date = item.formattedCreatedAt;

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
              _PengajuanBookCover(item: item, book: book),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: SubmissionSection.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          color: SubmissionSection.accentColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            institutionName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: SubmissionSection.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 14,
                      runSpacing: 5,
                      children: [
                        _MiniInfo(
                          icon: Icons.groups_rounded,
                          text: institutionType,
                        ),
                        _MiniInfo(
                          icon: Icons.inventory_2_outlined,
                          text: '${formatNumber(item.requestedQuantity)} buku',
                        ),
                        if (item.peopleCount != null && item.peopleCount! > 0)
                          _MiniInfo(
                            icon: Icons.people_alt_outlined,
                            text: '${formatNumber(item.peopleCount!)} jamaah',
                          ),
                      ],
                    ),

                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      _MiniInfo(
                        icon: Icons.location_on_outlined,
                        text: location,
                      ),
                    ],

                    const SizedBox(height: 8),

                    Container(height: 1, color: const Color(0xFFECEFF0)),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        _StatusChip(status: item.status),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            date.isNotEmpty ? date : 'Tanggal tidak tersedia',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
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

class _PengajuanBookCover extends StatelessWidget {
  const _PengajuanBookCover({required this.item, this.book});

  final BookRecipientModel item;
  final BookModel? book;

  @override
  Widget build(BuildContext context) {
    final title = book?.title.trim().isNotEmpty == true
        ? book!.title
        : item.bookTitle;

    final coverUrl = book?.coverUrl.trim() ?? '';

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
            Icons.fact_check_outlined,
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

BookModel? _findBookById(List<BookModel> books, int bookId) {
  for (final book in books) {
    if (book.id == bookId) {
      return book;
    }
  }

  return null;
}

BookModel? _bestBook({
  required BookRecipientModel item,
  required BookModel? catalogBook,
}) {
  final itemBook = item.book;

  if (itemBook != null && itemBook.coverUrl.trim().isNotEmpty) {
    return itemBook;
  }

  if (catalogBook != null && catalogBook.coverUrl.trim().isNotEmpty) {
    return catalogBook;
  }

  return itemBook ?? catalogBook;
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
        Flexible(
          child: Text(
            text,
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
      color = SubmissionSection.accentColor;
      icon = Icons.check_circle_rounded;
    } else if (normalized == 'rejected' || normalized == 'ditolak') {
      label = 'Ditolak';
      color = Colors.redAccent;
      icon = Icons.cancel_rounded;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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
              fontSize: 11.3,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PengajuanLoadingView extends StatelessWidget {
  const _PengajuanLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: SubmissionSection.primaryColor),
      ),
    );
  }
}

class _PengajuanEmptyView extends StatelessWidget {
  const _PengajuanEmptyView();

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
            Icons.assignment_outlined,
            color: SubmissionSection.primaryColor,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada pengajuan buku',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: SubmissionSection.primaryColor,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Buku yang sudah diajukan akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6D7476),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PengajuanLoginView extends StatelessWidget {
  const _PengajuanLoginView();

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
            Icons.lock_outline_rounded,
            color: SubmissionSection.primaryColor,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'Login diperlukan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: SubmissionSection.primaryColor,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Silahkan login untuk melihat daftar pengajuan buku.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6D7476),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PengajuanErrorView extends StatelessWidget {
  const _PengajuanErrorView({required this.message, required this.onRetry});

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
            message
                .replaceAll('Exception: ', '')
                .replaceAll('ApiException: ', ''),
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
              backgroundColor: SubmissionSection.primaryColor,
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

String formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
