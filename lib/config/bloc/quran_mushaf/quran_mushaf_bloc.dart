import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';
import 'package:puldapii/utils/services/home/quran_mushaf_service.dart';

part 'quran_mushaf_event.dart';
part 'quran_mushaf_state.dart';

class QuranMushafBloc extends Bloc<QuranMushafEvent, QuranMushafState> {
  final QuranMushafService service;

  QuranMushafBloc(this.service) : super(QuranMushafInitial()) {
    on<FetchMushafs>(_onFetchMushafs);
    on<FetchMushafDetail>(_onFetchMushafDetail);
    on<ChangeMushafPage>(_onChangeMushafPage);
    on<NextMushafPage>(_onNextMushafPage);
    on<PreviousMushafPage>(_onPreviousMushafPage);
  }

  Future<void> _onFetchMushafs(
    FetchMushafs event,
    Emitter<QuranMushafState> emit,
  ) async {
    emit(QuranMushafLoading());

    try {
      final mushafs = await service.getMushafs();
      emit(MushafsLoaded(mushafs));
    } catch (e) {
      emit(QuranMushafError(_cleanErrorMessage(e)));
    }
  }

  Future<void> _onFetchMushafDetail(
    FetchMushafDetail event,
    Emitter<QuranMushafState> emit,
  ) async {
    emit(QuranMushafLoading());

    try {
      final mushaf = await service.getMushafDetail(event.mushafId);

      final allAyahs = mushaf.surahs.expand((surah) => surah.ayahs).toList();
      final groupedPages = _groupAyahsByPage(allAyahs);

      if (groupedPages.isEmpty) {
        emit(QuranMushafError('Data halaman mushaf tidak tersedia'));
        return;
      }

      final sortedPages = groupedPages.keys.toList()..sort();
      final firstPage = sortedPages.first;
      final lastPage = sortedPages.last;

      int currentPage = event.initialPage;
      if (!groupedPages.containsKey(currentPage)) {
        currentPage = firstPage;
      }

      final currentPageAyahs = groupedPages[currentPage] ?? [];
      final computed = _computePageData(
        mushaf: mushaf,
        ayahs: currentPageAyahs,
      );

      emit(
        MushafDetailLoaded(
          mushaf: mushaf,
          currentPage: currentPage,
          totalPages: lastPage,
          currentPageAyahs: currentPageAyahs,
          groupedPages: groupedPages,
          currentSurahName: computed.currentSurahName,
          currentJuz: computed.currentJuz,
          ayahCount: computed.ayahCount,
          showTopBismillah: computed.showTopBismillah,
          segments: computed.segments,
        ),
      );
    } catch (e) {
      emit(QuranMushafError(_cleanErrorMessage(e)));
    }
  }

  void _onChangeMushafPage(
    ChangeMushafPage event,
    Emitter<QuranMushafState> emit,
  ) {
    final currentState = state;
    if (currentState is! MushafDetailLoaded) return;
    if (!currentState.groupedPages.containsKey(event.pageNumber)) return;

    final newAyahs = currentState.groupedPages[event.pageNumber] ?? [];
    final computed = _computePageData(
      mushaf: currentState.mushaf,
      ayahs: newAyahs,
    );

    emit(
      currentState.copyWith(
        currentPage: event.pageNumber,
        currentPageAyahs: newAyahs,
        currentSurahName: computed.currentSurahName,
        currentJuz: computed.currentJuz,
        ayahCount: computed.ayahCount,
        showTopBismillah: computed.showTopBismillah,
        segments: computed.segments,
      ),
    );
  }

  void _onNextMushafPage(NextMushafPage event, Emitter<QuranMushafState> emit) {
    final currentState = state;
    if (currentState is! MushafDetailLoaded) return;

    final pages = currentState.groupedPages.keys.toList()..sort();
    final currentIndex = pages.indexOf(currentState.currentPage);

    if (currentIndex == -1 || currentIndex >= pages.length - 1) return;

    final nextPage = pages[currentIndex + 1];
    final newAyahs = currentState.groupedPages[nextPage] ?? [];
    final computed = _computePageData(
      mushaf: currentState.mushaf,
      ayahs: newAyahs,
    );

    emit(
      currentState.copyWith(
        currentPage: nextPage,
        currentPageAyahs: newAyahs,
        currentSurahName: computed.currentSurahName,
        currentJuz: computed.currentJuz,
        ayahCount: computed.ayahCount,
        showTopBismillah: computed.showTopBismillah,
        segments: computed.segments,
      ),
    );
  }

  void _onPreviousMushafPage(
    PreviousMushafPage event,
    Emitter<QuranMushafState> emit,
  ) {
    final currentState = state;
    if (currentState is! MushafDetailLoaded) return;

    final pages = currentState.groupedPages.keys.toList()..sort();
    final currentIndex = pages.indexOf(currentState.currentPage);

    if (currentIndex <= 0) return;

    final previousPage = pages[currentIndex - 1];
    final newAyahs = currentState.groupedPages[previousPage] ?? [];
    final computed = _computePageData(
      mushaf: currentState.mushaf,
      ayahs: newAyahs,
    );

    emit(
      currentState.copyWith(
        currentPage: previousPage,
        currentPageAyahs: newAyahs,
        currentSurahName: computed.currentSurahName,
        currentJuz: computed.currentJuz,
        ayahCount: computed.ayahCount,
        showTopBismillah: computed.showTopBismillah,
        segments: computed.segments,
      ),
    );
  }

  Map<int, List<QuranAyahModel>> _groupAyahsByPage(List<QuranAyahModel> ayahs) {
    final Map<int, List<QuranAyahModel>> grouped = {};

    for (final ayah in ayahs) {
      final page = ayah.pageNumber;
      if (page <= 0) continue;

      grouped.putIfAbsent(page, () => []);
      grouped[page]!.add(ayah);
    }

    return grouped;
  }

  _MushafPageComputedData _computePageData({
    required QuranMushafModel mushaf,
    required List<QuranAyahModel> ayahs,
  }) {
    final currentSurahName = _getPrimarySurahName(ayahs, mushaf);
    final currentJuz = ayahs.isNotEmpty ? ayahs.first.juz : null;
    final ayahCount = ayahs.length;
    final showTopBismillah = _shouldShowBismillahOnTop(ayahs, mushaf);
    final segments = _buildSurahSegments(ayahs, mushaf);

    return _MushafPageComputedData(
      currentSurahName: currentSurahName,
      currentJuz: currentJuz,
      ayahCount: ayahCount,
      showTopBismillah: showTopBismillah,
      segments: segments,
    );
  }

  bool _shouldShowBismillahOnTop(
    List<QuranAyahModel> ayahs,
    QuranMushafModel mushaf,
  ) {
    if (ayahs.isEmpty) return false;

    final firstAyah = ayahs.first;
    final isStartOfSurah = firstAyah.number == 1;
    final isTaubah = firstAyah.surah == 9;
    final hasBismillah = (mushaf.bismillah ?? '').trim().isNotEmpty;

    return isStartOfSurah && !isTaubah && firstAyah.surah != 1 && hasBismillah;
  }

  List<List<QuranAyahModel>> _groupAyahsBySurah(List<QuranAyahModel> ayahs) {
    if (ayahs.isEmpty) return [];

    final groups = <List<QuranAyahModel>>[];
    List<QuranAyahModel> currentGroup = [ayahs.first];

    for (int i = 1; i < ayahs.length; i++) {
      final currentAyah = ayahs[i];
      final previousAyah = ayahs[i - 1];

      if (currentAyah.surah != previousAyah.surah) {
        groups.add(currentGroup);
        currentGroup = [currentAyah];
      } else {
        currentGroup.add(currentAyah);
      }
    }

    groups.add(currentGroup);
    return groups;
  }

  List<MushafPageSegment> _buildSurahSegments(
    List<QuranAyahModel> ayahs,
    QuranMushafModel mushaf,
  ) {
    if (ayahs.isEmpty) return [];

    final groups = _groupAyahsBySurah(ayahs);
    final segments = <MushafPageSegment>[];

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      final firstAyah = group.first;
      final isFirstGroup = i == 0;

      segments.add(
        MushafPageSegment(
          surahNumber: firstAyah.surah,
          surahName: _getSurahNameByNumber(firstAyah.surah, mushaf),
          arabicText: _buildArabicText(group),
          showDivider: !isFirstGroup,
          showBismillah:
              !isFirstGroup &&
              _shouldShowBismillahForInsertedSurah(firstAyah, mushaf),
        ),
      );
    }

    return segments;
  }

  String _buildArabicText(List<QuranAyahModel> ayahs) {
    if (ayahs.isEmpty) return '-';

    return ayahs
        .map((e) {
          final nomor = e.numberInHafs.isNotEmpty
              ? e.numberInHafs.first
              : e.number;
          return '${e.text} ﴿$nomor﴾';
        })
        .join('   ');
  }

  String _getPrimarySurahName(
    List<QuranAyahModel> ayahs,
    QuranMushafModel mushaf,
  ) {
    if (ayahs.isEmpty) return 'Al-Qur\'an';
    return _getSurahNameByNumber(ayahs.first.surah, mushaf);
  }

  String _getSurahNameByNumber(int surahNumber, QuranMushafModel mushaf) {
    final match = mushaf.surahs.cast<QuranSurahModel?>().firstWhere(
      (s) => s?.surahNumber == surahNumber || s?.id == surahNumber,
      orElse: () => null,
    );

    if (match != null && match.name.trim().isNotEmpty) {
      return match.name;
    }

    return 'Surah $surahNumber';
  }

  bool _shouldShowBismillahForInsertedSurah(
    QuranAyahModel firstAyah,
    QuranMushafModel mushaf,
  ) {
    final isStartOfSurah = firstAyah.number == 1;
    final isTaubah = firstAyah.surah == 9;
    final hasBismillah = (mushaf.bismillah ?? '').trim().isNotEmpty;

    return isStartOfSurah && !isTaubah && firstAyah.surah != 1 && hasBismillah;
  }

  String _cleanErrorMessage(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}

class _MushafPageComputedData {
  final String currentSurahName;
  final int? currentJuz;
  final int ayahCount;
  final bool showTopBismillah;
  final List<MushafPageSegment> segments;

  const _MushafPageComputedData({
    required this.currentSurahName,
    required this.currentJuz,
    required this.ayahCount,
    required this.showTopBismillah,
    required this.segments,
  });
}
