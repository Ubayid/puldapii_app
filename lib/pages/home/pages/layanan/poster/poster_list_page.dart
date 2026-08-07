import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:puldapii/config/bloc/poster_template/poster_template_bloc.dart';
import 'package:puldapii/models/poster_template_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/widget_filter_all.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';
import 'package:puldapii/utils/widget/widget_search.dart';
import 'package:share_plus/share_plus.dart';

class PosterDakwahPage extends StatefulWidget {
  const PosterDakwahPage({super.key});

  static const Color primaryColor = Color.fromRGBO(24, 100, 80, 1);

  @override
  State<PosterDakwahPage> createState() => _PosterDakwahPageState();
}

class _PosterDakwahPageState extends State<PosterDakwahPage> {
  final TextEditingController _searchController = TextEditingController();

  Set<int> _selectedCategoryIds = {};

  bool _showPager = false;

  void _setShowPager(bool value) {
    if (_showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  int _page = 1;
  static const int _perPage = 6;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetPage() {
    _page = 1;
    _showPager = false;
  }

  List<PosterTemplateModel> _getFilteredTemplates(
    List<PosterTemplateModel> templates,
  ) {
    final keyword = _searchController.text.trim().toLowerCase();

    return templates.where((template) {
      final matchSearch =
          keyword.isEmpty ||
          template.title.toLowerCase().contains(keyword) ||
          template.categories.any(
            (category) => category.name.toLowerCase().contains(keyword),
          );

      final matchCategory =
          _selectedCategoryIds.isEmpty ||
          template.categories.any(
            (category) => _selectedCategoryIds.contains(category.id),
          );

      return matchSearch && matchCategory;
    }).toList();
  }

  List<PosterTemplateModel> _getPagedTemplates(
    List<PosterTemplateModel> templates,
  ) {
    final start = (_page - 1) * _perPage;
    final end = start + _perPage;

    if (start >= templates.length) return [];

    return templates.sublist(
      start,
      end > templates.length ? templates.length : end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(onChatTap: () {}),

            Expanded(
              child: BlocBuilder<PosterTemplateBloc, PosterTemplateState>(
                builder: (context, state) {
                  if (state is PosterTemplateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PosterTemplateError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is PosterTemplateHomeLoaded) {
                    final filteredTemplates = _getFilteredTemplates(
                      state.templates,
                    );

                    final totalPage = (filteredTemplates.length / _perPage)
                        .ceil();

                    if (_page > totalPage && totalPage > 0) {
                      _page = totalPage;
                    }

                    final pagedTemplates = _getPagedTemplates(
                      filteredTemplates,
                    );
                    final hasNextPage = _page < totalPage;

                    final categoryOptions = state.categories.map((category) {
                      return FilterOption(id: category.id, name: category.name);
                    }).toList();

                    final bannerTemplates = state.templates
                        .where((template) => template.isBanner)
                        .take(5)
                        .toList();

                    return GradientPage(
                      child: Stack(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() {
                                _showPager = !_showPager;
                              });
                            },
                            child: NotificationListener<UserScrollNotification>(
                              onNotification: (notification) {
                                if (notification.metrics.axis ==
                                    Axis.vertical) {
                                  if (notification.direction ==
                                      ScrollDirection.reverse) {
                                    // Scroll ke bawah, pager muncul
                                    _setShowPager(true);
                                  } else if (notification.direction ==
                                      ScrollDirection.forward) {
                                    // Scroll ke atas, pager hilang
                                    _setShowPager(false);
                                  }
                                }

                                return false;
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppSearchBar(
                                      controller: _searchController,
                                      hintText: 'Cari template poster...',
                                      onChanged: (_) {
                                        setState(() {
                                          _resetPage();
                                        });
                                      },
                                      onClear: () {
                                        _searchController.clear();
                                        setState(() {
                                          _resetPage();
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    FilterSection(
                                      options: categoryOptions,
                                      selectedIds: _selectedCategoryIds,
                                      buttonLabel: 'Kategori',
                                      sheetTitle: 'Pilih Kategori',
                                      applyText: 'Terapkan',
                                      loadingText: 'Belum ada kategori',
                                      columns: 3,
                                      onApply: (ids) {
                                        setState(() {
                                          _selectedCategoryIds = ids;
                                          _resetPage();
                                        });
                                      },
                                      onRemoveTag: (id) {
                                        setState(() {
                                          _selectedCategoryIds.remove(id);
                                          _resetPage();
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    if (bannerTemplates.isNotEmpty)
                                      _HeroBannerCarousel(
                                        templates: bannerTemplates,
                                      )
                                    else
                                      const _EmptyBanner(),

                                    const SizedBox(height: 12),

                                    if (pagedTemplates.isNotEmpty)
                                      _PopularTemplateGrid(
                                        templates: pagedTemplates,
                                      )
                                    else
                                      const _EmptyText(
                                        message:
                                            'Tidak ada template yang sesuai',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          FloatingPager(
                            showPager: _showPager,
                            page: _page,
                            isLoading: false,
                            hasNextPage: hasNextPage,
                            onPageChanged: (newPage) {
                              setState(() {
                                _page = newPage;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBannerCarousel extends StatefulWidget {
  const _HeroBannerCarousel({required this.templates});

  final List<PosterTemplateModel> templates;

  @override
  State<_HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<_HeroBannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final banners = widget.templates;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _openPreview(context, banners[_currentIndex]);
          },
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CarouselSlider.builder(
                  itemCount: banners.length,
                  itemBuilder: (context, index, realIndex) {
                    final template = banners[index];

                    return Image.network(
                      template.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      headers: const {'User-Agent': 'Mozilla/5.0'},
                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 48),
                        );
                      },
                    );
                  },
                  options: CarouselOptions(
                    height: 180,
                    viewportFraction: 1,
                    enableInfiniteScroll: banners.length > 1,
                    autoPlay: banners.length > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 700,
                    ),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),

                Container(color: Colors.black.withOpacity(0.28)),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Text(
                          'Tema Pekan Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isActive = index == _currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? PosterDakwahPage.primaryColor
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _PopularTemplateGrid extends StatelessWidget {
  const _PopularTemplateGrid({required this.templates});

  final List<PosterTemplateModel> templates;

  @override
  Widget build(BuildContext context) {
    final displayedTemplates = templates;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedTemplates.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return _PosterCard(template: displayedTemplates[index]);
      },
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.template});

  final PosterTemplateModel template;

  @override
  Widget build(BuildContext context) {
    debugPrint('POSTER IMAGE URL: ${template.imageUrl}');

    return GestureDetector(
      onTap: () => _openPreview(context, template),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              template.imageUrl,
              fit: BoxFit.cover,
              headers: const {'User-Agent': 'Mozilla/5.0'},
              errorBuilder: (_, error, ___) {
                debugPrint('POSTER IMAGE ERROR: $error');

                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _openPreview(BuildContext context, PosterTemplateModel template) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.78),
    barrierDismissible: true,
    builder: (dialogContext) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(dialogContext).pop();
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(18),
          child: GestureDetector(
            onTap: () {},
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        template.imageUrl,
                        fit: BoxFit.contain,
                        headers: const {'User-Agent': 'Mozilla/5.0'},
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              size: 70,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkResponse(
                          radius: 22,
                          containedInkWell: true,
                          customBorder: const CircleBorder(),
                          splashColor: Colors.white.withOpacity(0.25),
                          highlightColor: Colors.white.withOpacity(0.15),
                          onTap: () {
                            _downloadPoster(
                              context: dialogContext,
                              imageUrl: template.imageUrl,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _downloadPoster({
  required BuildContext context,
  required String imageUrl,
}) async {
  _showOverlayMessage(context, 'Mengunduh poster...');

  try {
    final response = await Dio().get<List<int>>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: const {'User-Agent': 'Mozilla/5.0'},
      ),
    );

    final bytes = Uint8List.fromList(response.data ?? []);

    if (bytes.isEmpty) {
      throw Exception('File gambar kosong');
    }

    final tempDir = await getTemporaryDirectory();

    final file = File(
      '${tempDir.path}/poster_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Poster Dakwah');

    _showOverlayMessage(context, 'Pilih aplikasi tujuan atau Simpan ke File');
  } catch (e) {
    _showOverlayMessage(context, 'Gagal download poster.');
  }
}

void _showOverlayMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);

  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 20,
        right: 20,
        bottom: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
    overlayEntry.remove();
  });
}

class PosterTemplateListPage extends StatelessWidget {
  const PosterTemplateListPage({
    super.key,
    required this.title,
    required this.templates,
  });

  final String title;
  final List<PosterTemplateModel> templates;

  static const Color primaryColor = PosterDakwahPage.primaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F4),
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF073F36),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: templates.isEmpty
          ? const Center(child: Text('Belum ada template'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return _PosterCard(template: templates[index]);
              },
            ),
    );
  }
}

class _EmptyBanner extends StatelessWidget {
  const _EmptyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Belum ada banner',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
      ),
    );
  }
}
