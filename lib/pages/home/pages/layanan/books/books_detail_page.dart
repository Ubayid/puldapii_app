import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/book_bloc/book_bloc.dart';
import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/utils/services/home/book_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({super.key, required this.idOrSlug});

  final String idOrSlug;

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookBloc(BookService())..add(FetchBookDetail(idOrSlug)),
      child: const _BookDetailView(),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: Column(
        children: [
          SecondaryHeader(title: "Detail Buku"),

          Expanded(
            child: GradientPage(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: BlocBuilder<BookBloc, BookState>(
                  builder: (context, state) {
                    if (state is BookLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: BookDetailPage.primaryColor,
                        ),
                      );
                    }

                    if (state is BookError) {
                      return _DetailErrorView(
                        message: state.message,
                        onBack: () => Navigator.pop(context),
                      );
                    }

                    if (state is BookDetailLoaded) {
                      return _DetailContent(book: state.book);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    final title = _cleanText(book.title, fallback: 'Judul Buku');
    final category = _cleanText(
      book.category?.name,
      fallback: 'Tanpa Kategori',
    );
    final description = _cleanText(book.description);
    final author = _cleanText(book.author, fallback: 'Penulis belum tersedia');

    final pages = book.totalPages;
    final price = book.printCost;
    final target = book.targetQuantity;
    final collected = book.collectedQuantity;

    final percent = book.progressPercent.clamp(0, 100);
    final percentage = (percent / 100).clamp(0.0, 1.0);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _BookSummaryCard(
                  book: book,
                  title: title,
                  author: author,
                  category: category,
                  pages: pages,
                  price: price,
                  target: target,
                  collected: collected,
                  percentage: percentage,
                  percent: percent,
                ),

                const SizedBox(height: 12),

                _IconDescriptionCard(
                  title: 'Deskripsi Buku',
                  text: description.isEmpty
                      ? 'Belum ada deskripsi buku.'
                      : description,
                ),

                const SizedBox(height: 12),

                _BenefitsCard(benefits: book.benefits),

                const SizedBox(height: 12),

                _PreviewBookCard(previewImages: book.previewImages),

                const SizedBox(height: 14),

                _ActionButtonSection(
                  onTaawunTap: () {
                    _showOverlayMessage(
                      context,
                      'Fitur masih dalam pengembangan',
                    );
                  },
                  onPengajuanTap: () {
                    _showOverlayMessage(
                      context,
                      'Fitur masih dalam pengembangan',
                    );
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookSummaryCard extends StatelessWidget {
  const _BookSummaryCard({
    required this.book,
    required this.title,
    required this.author,
    required this.category,
    required this.pages,
    required this.price,
    required this.target,
    required this.collected,
    required this.percentage,
    required this.percent,
  });

  final BookModel book;
  final String title;
  final String author;
  final String category;
  final int pages;
  final int price;
  final int target;
  final int collected;
  final double percentage;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final coverUrl = book.coverUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 105,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: coverUrl.isNotEmpty
                ? Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _DefaultBookThumb(title: title);
                    },
                  )
                : _DefaultBookThumb(title: title),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: BookDetailPage.primaryColor,
                  ),
                ),

                const SizedBox(height: 10),

                _SummaryLine(
                  icon: Icons.person_outline_rounded,
                  label: 'Penulis',
                  value: author,
                ),
                _SummaryLine(
                  icon: Icons.local_offer_outlined,
                  label: 'Kategori',
                  value: category,
                  valueColor: const Color(0xFF12A99C),
                ),
                _SummaryLine(
                  icon: Icons.menu_book_outlined,
                  label: null,
                  value: '$pages hlm',
                ),
                _SummaryLine(
                  icon: Icons.print_outlined,
                  label: 'Cetak',
                  value: 'Rp${formatRupiah(price)}/buku',
                ),

                const SizedBox(height: 6),

                Divider(color: Colors.black.withOpacity(0.08)),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Target: ${formatNumber(target)} buku',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4D4F),
                        ),
                      ),
                    ),
                    Text(
                      'Terkumpul: ',
                      style: TextStyle(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.65),
                      ),
                    ),
                    Text(
                      '${formatNumber(collected)} buku',
                      style: const TextStyle(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF12A99C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEDEDED),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF12A99C),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E4D4F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.icon,
    required this.value,
    this.label,
    this.valueColor,
  });

  final IconData icon;
  final String? label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3E4D4F)),
          const SizedBox(width: 8),
          if (label != null)
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF3E4D4F),
                fontWeight: FontWeight.w600,
              ),
            ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? const Color(0xFF3E4D4F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultBookThumb extends StatelessWidget {
  const _DefaultBookThumb({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BookDetailPage.primaryColor,
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _IconDescriptionCard extends StatelessWidget {
  const _IconDescriptionCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: BookDetailPage.primaryColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13.3,
                    height: 1.45,
                    color: Color(0xFF3E4D4F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    final items = benefits.where((item) => item.trim().isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manfaat & Sasaran',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: BookDetailPage.primaryColor,
                  ),
                ),

                const SizedBox(height: 6),

                if (items.isEmpty)
                  const Text(
                    'Belum ada manfaat buku.',
                    style: TextStyle(
                      fontSize: 13.3,
                      height: 1.45,
                      color: Color(0xFF3E4D4F),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Column(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                size: 7,
                                color: Color(0xFF12A99C),
                              ),
                            ),

                            const SizedBox(width: 9),

                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 13.3,
                                  height: 1.35,
                                  color: Color(0xFF3E4D4F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBookCard extends StatelessWidget {
  const _PreviewBookCard({required this.previewImages});

  final List<BookPreviewImageModel> previewImages;

  @override
  Widget build(BuildContext context) {
    final images = previewImages
        .where((item) => item.imageUrl.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: images.isEmpty
                ? const Text(
                    'Belum ada preview halaman buku.',
                    style: TextStyle(
                      fontSize: 12.8,
                      height: 1.55,
                      color: Color(0xFF3E4D4F),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : CarouselSlider.builder(
                    itemCount: images.length,
                    options: CarouselOptions(
                      height: 145,
                      viewportFraction: 0.36,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: false,
                      padEnds: false,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final imageUrl = images[index].imageUrl;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            _showPreviewImageDialog(context, imageUrl);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: const Color(0xFFEDEDED),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;

                                      return const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: BookDetailPage.primaryColor,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (_, __, ___) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonSection extends StatelessWidget {
  const _ActionButtonSection({
    required this.onTaawunTap,
    required this.onPengajuanTap,
  });

  final VoidCallback onTaawunTap;
  final VoidCallback onPengajuanTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionCard(
          color: const Color(0xFF12A99C),
          icon: Icons.print_rounded,
          title: 'Taawun Pencetakan Buku',
          subtitle: 'Dukung biaya cetak buku',
          textColor: Colors.white,
          onTap: onTaawunTap,
        ),

        const SizedBox(height: 10),

        _ActionCard(
          color: const Color(0xFFFFB91D),
          icon: Icons.groups_rounded,
          title: 'Pengajuan Penerima Buku',
          subtitle: 'Ajukan sebagai penerima',
          textColor: Colors.black,
          onTap: onPengajuanTap,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkText = textColor == Colors.black;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 27),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkText
                            ? Colors.black.withOpacity(0.72)
                            : Colors.white.withOpacity(0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: textColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),

          const Spacer(),

          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 46,
          ),

          const SizedBox(height: 12),

          Text(
            message.replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3E4D4F),
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 9,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

void _showOverlayMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 20,
        right: 20,
        bottom: 86,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

void _showPreviewImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.7,
                maxScale: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Gagal memuat gambar preview.',
                          style: TextStyle(
                            color: Color(0xFF3E4D4F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
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

String _cleanText(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}
