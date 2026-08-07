import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:puldapii/config/bloc/quran_mushaf_image_bloc/quran_mushaf_image_bloc.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class QuranMushafImagePage extends StatefulWidget {
  final int mushafId;
  final int initialPage;

  const QuranMushafImagePage({
    super.key,
    this.mushafId = 1,
    this.initialPage = 1,
  });

  @override
  State<QuranMushafImagePage> createState() => _QuranMushafImagePageState();
}

class _QuranMushafImagePageState extends State<QuranMushafImagePage> {
  late PageController _pageController;

  int? _selectedJuz;
  int? _selectedSurahId;
  int? _selectedAyahNumber;

  int? _lastPrecachedPage;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.initialPage - 1);

    context.read<QuranMushafImageBloc>().add(
      FetchQuranMushafImage(widget.mushafId, initialPage: widget.initialPage),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  String _getMushafSlug(QuranMushafModel mushaf) {
    final url = mushaf.imagesPng?.isNotEmpty == true
        ? mushaf.imagesPng!
        : (mushaf.images ?? '');

    if (url.isEmpty) return 'hafs';

    final filename = Uri.parse(url).pathSegments.last;

    return filename.replaceAll('.zip', '');
  }

  String _getMushafPageUrl(QuranMushafModel mushaf, int page) {
    final slug = _getMushafSlug(mushaf);

    return 'https://layanan.puldapii.or.id/api/quran/mushaf-page/$slug/$page';
  }

  int? _getPageFromJuz(int juz) {
    const juzStartPages = {
      1: 1,
      2: 22,
      3: 42,
      4: 62,
      5: 82,
      6: 102,
      7: 121,
      8: 142,
      9: 162,
      10: 182,
      11: 201,
      12: 222,
      13: 242,
      14: 262,
      15: 282,
      16: 302,
      17: 322,
      18: 342,
      19: 362,
      20: 382,
      21: 402,
      22: 422,
      23: 442,
      24: 462,
      25: 482,
      26: 502,
      27: 522,
      28: 542,
      29: 562,
      30: 582,
    };

    return juzStartPages[juz];
  }

  List<_SurahOption> _buildSurahOptions(QuranMushafModel mushaf) {
    return mushaf.surahs.map((surah) {
      final ayahs = surah.ayahs;
      final startPage = ayahs.isNotEmpty ? ayahs.first.pageNumber : 1;

      return _SurahOption(
        id: surah.id,
        surahNumber: surah.surahNumber,
        name: surah.name,
        startPage: startPage,
        totalAyah: ayahs.length,
      );
    }).toList();
  }

  List<_AyahOption> _buildAyahOptions(QuranMushafModel mushaf, int surahId) {
    final QuranSurahModel? surah = mushaf.surahs
        .cast<QuranSurahModel?>()
        .firstWhere((item) => item?.id == surahId, orElse: () => null);

    if (surah == null) return [];

    return surah.ayahs.map((ayah) {
      return _AyahOption(ayahNumber: ayah.number, page: ayah.pageNumber);
    }).toList();
  }

  int? _findCurrentSurahIdFromPage(
    QuranMushafModel mushaf,
    List<QuranAyahModel> currentPageAyahs,
  ) {
    if (currentPageAyahs.isEmpty) return null;

    final currentSurahNumber = currentPageAyahs.first.surah;

    final QuranSurahModel? match = mushaf.surahs
        .cast<QuranSurahModel?>()
        .firstWhere(
          (surah) =>
              surah?.surahNumber == currentSurahNumber ||
              surah?.id == currentSurahNumber,
          orElse: () => null,
        );

    return match?.id;
  }

  void _syncDropdownSelection(QuranMushafImageLoaded state) {
    final currentSurahId = _findCurrentSurahIdFromPage(
      state.mushaf,
      state.currentPageAyahs,
    );

    final shouldUpdateJuz = _selectedJuz != state.currentJuz;
    final shouldUpdateSurah = _selectedSurahId != currentSurahId;

    if (shouldUpdateJuz || shouldUpdateSurah) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _selectedJuz = state.currentJuz;
          _selectedSurahId = currentSurahId;
          _selectedAyahNumber = null;
        });
      });
    }
  }

  void _changePage(int page, {bool animate = false}) {
    final targetIndex = page - 1;

    if (_pageController.hasClients) {
      if (animate) {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _pageController.jumpToPage(targetIndex);
      }
    }

    context.read<QuranMushafImageBloc>().add(ChangeQuranMushafImagePage(page));
  }

  void _precacheAroundPage(
    QuranMushafModel mushaf,
    int currentPage,
    int totalPages,
  ) {
    if (_lastPrecachedPage == currentPage) return;
    _lastPrecachedPage = currentPage;

    final pages = [currentPage, currentPage - 1, currentPage + 1];

    for (final page in pages) {
      if (page < 1 || page > totalPages) continue;

      final url = _getMushafPageUrl(mushaf, page);

      unawaited(MushafSvgCache.load(url).catchError((_) => ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SecondaryHeader(title: 'Al-Qur\'an'),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<QuranMushafImageBloc, QuranMushafImageState>(
                builder: (context, state) {
                  if (state is QuranMushafImageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is QuranMushafImageError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(state.message, textAlign: TextAlign.center),
                      ),
                    );
                  }

                  if (state is QuranMushafImageLoaded) {
                    _syncDropdownSelection(state);

                    final mushaf = state.mushaf;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      _precacheAroundPage(
                        mushaf,
                        state.currentPage,
                        state.totalPages,
                      );
                    });

                    final surahOptions = _buildSurahOptions(mushaf);

                    final ayahOptions = _selectedSurahId != null
                        ? _buildAyahOptions(mushaf, _selectedSurahId!)
                        : <_AyahOption>[];

                    final validAyahValue =
                        ayahOptions.any(
                          (ayah) => ayah.ayahNumber == _selectedAyahNumber,
                        )
                        ? _selectedAyahNumber
                        : null;

                    final currentSurahTotalAyah = surahOptions
                        .firstWhere(
                          (surah) => surah.name == state.currentSurahName,
                          orElse: () => const _SurahOption(
                            id: 0,
                            surahNumber: 0,
                            name: '',
                            startPage: 1,
                            totalAyah: 0,
                          ),
                        )
                        .totalAyah;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),

                          _CardContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        state.currentJuz != null
                                            ? 'Juz ${state.currentJuz}'
                                            : '-',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        state.currentSurahName,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '$currentSurahTotalAyah Ayat',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          _CardContainer(
                            child: GestureDetector(
                              onTap: () {
                                _showFullPageMushaf(
                                  mushaf: mushaf,
                                  state: state,
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 520,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: PageView.builder(
                                            controller: _pageController,
                                            itemCount: state.totalPages,
                                            reverse: true,
                                            onPageChanged: (index) {
                                              final page = index + 1;

                                              context
                                                  .read<QuranMushafImageBloc>()
                                                  .add(
                                                    ChangeQuranMushafImagePage(
                                                      page,
                                                    ),
                                                  );
                                            },
                                            itemBuilder: (context, index) {
                                              final page = index + 1;

                                              return InteractiveViewer(
                                                minScale: 1,
                                                maxScale: 4,
                                                child: CachedMushafSvgPage(
                                                  key: ValueKey(
                                                    'mushaf-page-$page',
                                                  ),
                                                  url: _getMushafPageUrl(
                                                    mushaf,
                                                    page,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${state.currentPage}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w700,
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

                          const SizedBox(height: 14),

                          _CardContainer(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedJuz,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    decoration: _dropdownDecoration('Juz'),
                                    borderRadius: BorderRadius.circular(14),
                                    dropdownColor: Colors.white,
                                    items: List.generate(
                                      30,
                                      (index) => DropdownMenuItem<int>(
                                        value: index + 1,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value == null) return;

                                      final page = _getPageFromJuz(value);
                                      if (page == null) return;

                                      setState(() {
                                        _selectedJuz = value;
                                        _selectedAyahNumber = null;
                                      });

                                      _changePage(page);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedSurahId,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    decoration: _dropdownDecoration('Surat'),
                                    borderRadius: BorderRadius.circular(14),
                                    dropdownColor: Colors.white,
                                    items: surahOptions.map((surah) {
                                      return DropdownMenuItem<int>(
                                        value: surah.id,
                                        child: Text(
                                          surah.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value == null) return;

                                      final selectedSurah = surahOptions
                                          .firstWhere(
                                            (surah) => surah.id == value,
                                          );

                                      setState(() {
                                        _selectedSurahId = value;
                                        _selectedAyahNumber = null;
                                      });

                                      _changePage(selectedSurah.startPage);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<int>(
                                    value: validAyahValue,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    decoration: _dropdownDecoration('Ayat'),
                                    borderRadius: BorderRadius.circular(14),
                                    dropdownColor: Colors.white,
                                    items: ayahOptions.map((ayah) {
                                      return DropdownMenuItem<int>(
                                        value: ayah.ayahNumber,
                                        child: Text(
                                          '${ayah.ayahNumber}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: ayahOptions.isEmpty
                                        ? null
                                        : (value) {
                                            if (value == null) return;

                                            final selectedAyah = ayahOptions
                                                .firstWhere(
                                                  (ayah) =>
                                                      ayah.ayahNumber == value,
                                                );

                                            setState(() {
                                              _selectedAyahNumber = value;
                                            });

                                            _changePage(selectedAyah.page);
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      state.currentPage < state.totalPages
                                      ? () => _changePage(
                                          state.currentPage + 1,
                                          animate: true,
                                        )
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                  label: const Text('Berikutnya'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(
                                      68,
                                      174,
                                      183,
                                      1,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: state.currentPage > 1
                                      ? () => _changePage(
                                          state.currentPage - 1,
                                          animate: true,
                                        )
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                  label: const Text('Sebelumnya'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(width: 1.4),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  void _showFullPageMushaf({
    required QuranMushafModel mushaf,
    required QuranMushafImageLoaded state,
  }) {
    int currentPopupPage = state.currentPage;

    final fullscreenController = PageController(
      initialPage: state.currentPage - 1,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Material(
              color: Colors.white,
              child: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: fullscreenController,
                      itemCount: state.totalPages,
                      reverse: true,
                      onPageChanged: (index) {
                        final page = index + 1;

                        setDialogState(() {
                          currentPopupPage = page;
                        });

                        context.read<QuranMushafImageBloc>().add(
                          ChangeQuranMushafImagePage(page),
                        );

                        _pageController.jumpToPage(index);
                      },
                      itemBuilder: (context, index) {
                        final page = index + 1;

                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 5,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(10, 46, 10, 46),
                            child: CachedMushafSvgPage(
                              key: ValueKey('fullscreen-mushaf-page-$page'),
                              url: _getMushafPageUrl(mushaf, page),
                            ),
                          ),
                        );
                      },
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.black87,
                          size: 30,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 18,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            '$currentPopupPage',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      fullscreenController.dispose();
    });
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SurahOption {
  final int id;
  final int surahNumber;
  final String name;
  final int startPage;
  final int totalAyah;

  const _SurahOption({
    required this.id,
    required this.surahNumber,
    required this.name,
    required this.startPage,
    required this.totalAyah,
  });
}

class _AyahOption {
  final int ayahNumber;
  final int page;

  const _AyahOption({required this.ayahNumber, required this.page});
}

class MushafSvgCache {
  static final Map<String, String> _cache = {};

  static Future<String> load(String url) async {
    final cached = _cache[url];
    if (cached != null) return cached;

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat halaman mushaf');
    }

    final svg = response.body;
    _cache[url] = svg;

    return svg;
  }
}

class CachedMushafSvgPage extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const CachedMushafSvgPage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  @override
  State<CachedMushafSvgPage> createState() => _CachedMushafSvgPageState();
}

class _CachedMushafSvgPageState extends State<CachedMushafSvgPage> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CachedMushafSvgPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _load();
    }
  }

  void _load() {
    _future = MushafSvgCache.load(widget.url);
  }

  void _retry() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 36),
                const SizedBox(height: 8),
                const Text(
                  'Gagal memuat halaman',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }

        return SvgPicture.string(snapshot.data!, fit: widget.fit);
      },
    );
  }
}
