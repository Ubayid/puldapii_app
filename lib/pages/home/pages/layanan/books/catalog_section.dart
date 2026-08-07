import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/book_bloc/book_bloc.dart';
import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/pages/home/pages/layanan/books/books_detail_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.onShowMessage});

  final ValueChanged<String> onShowMessage;

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Katalog Buku',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: primaryColor,
          ),
        ),

        const SizedBox(height: 10),

        BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            if (state is BookLoading) {
              return const _BookLoadingView();
            }

            if (state is BookError) {
              return _BookErrorView(
                message: state.message,
                onRetry: () {
                  context.read<BookBloc>().add(
                    FetchBooks(page: 1, perPage: 20),
                  );
                },
              );
            }

            if (state is BooksLoaded) {
              if (state.books.isEmpty) {
                return const _BookEmptyView();
              }

              return Column(
                children: state.books.map((book) {
                  final idOrSlug = _bookIdOrSlug(book);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _BookCampaignCard(
                      book: book,
                      onDetailTap: () {
                        if (idOrSlug.isEmpty) {
                          onShowMessage('Detail buku tidak tersedia');
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailPage(idOrSlug: idOrSlug),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _BookCampaignCard extends StatelessWidget {
  const _BookCampaignCard({required this.book, required this.onDetailTap});

  final BookModel book;
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    final title = book.title.isNotEmpty ? book.title : 'Judul Buku';
    final category = book.category?.name ?? '-';
    final pages = book.totalPages;
    final price = book.printCost;
    final target = book.targetQuantity;
    final progress = book.collectedQuantity;
    final percent = book.progressPercent;
    final percentage = (percent / 100).clamp(0.0, 1.0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onDetailTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(book: book),
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
                        color: CatalogPage.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          color: Color(0xFF12A99C),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Kategori: $category',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF12A99C),
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
                          icon: Icons.menu_book_outlined,
                          text: '$pages hlm',
                        ),
                        _MiniInfo(
                          icon: Icons.print_outlined,
                          text: 'Rp${formatRupiah(price)}/buku',
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
                            'Target: ${formatNumber(target)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF3E4D4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${formatNumber(progress)} buku',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF12A99C),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFEDEDED),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF12A99C),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF3E4D4F),
                            fontWeight: FontWeight.w800,
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

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final coverUrl = book.coverUrl;
    final title = book.title.isNotEmpty ? book.title : 'Judul Buku';

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
            Icons.mosque_outlined,
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

class _BookLoadingView extends StatelessWidget {
  const _BookLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(color: CatalogPage.primaryColor),
      ),
    );
  }
}

class _BookEmptyView extends StatelessWidget {
  const _BookEmptyView();

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
            Icons.menu_book_outlined,
            color: CatalogPage.primaryColor,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada buku tersedia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: CatalogPage.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookErrorView extends StatelessWidget {
  const _BookErrorView({required this.message, required this.onRetry});

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
              backgroundColor: CatalogPage.primaryColor,
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

String formatRupiah(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}

String formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}

String _bookIdOrSlug(BookModel book) {
  return book.slug.isNotEmpty ? book.slug : book.id.toString();
}
