import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/quran_mushaf/quran_mushaf_bloc.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class QuranMushafPage extends StatefulWidget {
  final int mushafId;
  final int initialPage;

  const QuranMushafPage({super.key, this.mushafId = 1, this.initialPage = 1});

  @override
  State<QuranMushafPage> createState() => _QuranMushafPageState();
}

class _QuranMushafPageState extends State<QuranMushafPage> {
  int? _selectedJuz;
  int? _selectedSurahId;
  int? _selectedAyahNumber;

  @override
  void initState() {
    super.initState();
    context.read<QuranMushafBloc>().add(
      FetchMushafDetail(widget.mushafId, initialPage: widget.initialPage),
    );
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

  void _syncDropdownSelection(MushafDetailLoaded state) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SecondaryHeader(title: 'Al-Qur\'an'),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<QuranMushafBloc, QuranMushafState>(
                builder: (context, state) {
                  if (state is QuranMushafLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is QuranMushafError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(state.message, textAlign: TextAlign.center),
                      ),
                    );
                  }

                  if (state is MushafDetailLoaded) {
                    _syncDropdownSelection(state);

                    final mushaf = state.mushaf;
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
                    final quranTextStyle = TextStyle(
                      fontSize: 11,
                      height: 2.0,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w500,
                    );

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
                            child: Container(
                              width: double.infinity,
                              height: 440, // fixed height
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (state.showTopBismillah) ...[
                                      Text(
                                        (mushaf.bismillah ?? '').trim(),
                                        textAlign: TextAlign.center,
                                        style: quranTextStyle,
                                      ),
                                    ],

                                    if (state.segments.isEmpty)
                                      const Text(
                                        '-',
                                        textAlign: TextAlign.center,
                                      ),

                                    ...state.segments.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final segment = entry.value;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (segment.showDivider) ...[
                                            _buildSurahDivider(
                                              segment.surahName,
                                              quranTextStyle,
                                            ),
                                          ],
                                          if (segment.showBismillah) ...[
                                            Text(
                                              (mushaf.bismillah ?? '').trim(),
                                              textAlign: TextAlign.center,
                                              style: quranTextStyle,
                                            ),
                                          ],
                                          Text(
                                            segment.arabicText,
                                            textAlign: TextAlign.justify,
                                            style: quranTextStyle,
                                          ),
                                          if (index !=
                                                  state.segments.length - 1 &&
                                              !segment.showDivider)
                                            const SizedBox(height: 0),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _CardContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
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

                                          context.read<QuranMushafBloc>().add(
                                            ChangeMushafPage(page),
                                          );
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
                                        decoration: _dropdownDecoration(
                                          'Surat',
                                        ),
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

                                          context.read<QuranMushafBloc>().add(
                                            ChangeMushafPage(
                                              selectedSurah.startPage,
                                            ),
                                          );
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
                                                          ayah.ayahNumber ==
                                                          value,
                                                    );

                                                setState(() {
                                                  _selectedAyahNumber = value;
                                                });

                                                context
                                                    .read<QuranMushafBloc>()
                                                    .add(
                                                      ChangeMushafPage(
                                                        selectedAyah.page,
                                                      ),
                                                    );
                                              },
                                      ),
                                    ),
                                  ],
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
                                      ? () {
                                          context.read<QuranMushafBloc>().add(
                                            NextMushafPage(),
                                          );
                                        }
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
                                      ? () {
                                          context.read<QuranMushafBloc>().add(
                                            PreviousMushafPage(),
                                          );
                                        }
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

  Widget _buildSurahDivider(String title, TextStyle quranTextStyle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.withOpacity(0.25)),
      ),
      child: Text(title, textAlign: TextAlign.center, style: quranTextStyle),
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
