import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:puldapii/models/quran_mushaf_model.dart';
import 'package:puldapii/utils/services/home/quran_mushaf_service.dart';

part 'quran_mushaf_image_event.dart';
part 'quran_mushaf_image_state.dart';

class QuranMushafImageBloc
    extends Bloc<QuranMushafImageEvent, QuranMushafImageState> {
  final QuranMushafService service;

  QuranMushafImageBloc(this.service) : super(QuranMushafImageInitial()) {
    on<FetchQuranMushafImage>(_onFetchQuranMushafImage);
    on<ChangeQuranMushafImagePage>(_onChangeQuranMushafImagePage);
    on<NextQuranMushafImagePage>(_onNextQuranMushafImagePage);
    on<PreviousQuranMushafImagePage>(_onPreviousQuranMushafImagePage);
    on<RefreshQuranMushafImagePage>(_onRefreshQuranMushafImagePage);
  }

  Future<void> _onFetchQuranMushafImage(
    FetchQuranMushafImage event,
    Emitter<QuranMushafImageState> emit,
  ) async {
    final targetPage = _normalizePage(event.initialPage);

    emit(QuranMushafImageLoading(currentPage: targetPage));

    try {
      final mushaf = await service.getMushafDetail(event.mushafId);

      final allAyahs = _getAllAyahs(mushaf);
      final currentPageAyahs = _getAyahsByPage(allAyahs, targetPage);

      emit(
        QuranMushafImageLoaded(
          mushaf: mushaf,
          currentPage: targetPage,
          totalPages: 604,
          currentPageAyahs: currentPageAyahs,
          currentJuz: _getCurrentJuz(currentPageAyahs),
          currentSurahName: _getCurrentSurahName(mushaf, currentPageAyahs),
          imagesPngUrl: mushaf.imagesPng,
        ),
      );
    } catch (e) {
      emit(
        QuranMushafImageError(currentPage: targetPage, message: _cleanError(e)),
      );
    }
  }

  Future<void> _onChangeQuranMushafImagePage(
    ChangeQuranMushafImagePage event,
    Emitter<QuranMushafImageState> emit,
  ) async {
    final currentState = state;

    if (currentState is! QuranMushafImageLoaded) return;

    final targetPage = _normalizePage(event.page);

    final allAyahs = _getAllAyahs(currentState.mushaf);
    final currentPageAyahs = _getAyahsByPage(allAyahs, targetPage);

    emit(
      currentState.copyWith(
        currentPage: targetPage,
        currentPageAyahs: currentPageAyahs,
        currentJuz: _getCurrentJuz(currentPageAyahs),
        currentSurahName: _getCurrentSurahName(
          currentState.mushaf,
          currentPageAyahs,
        ),
      ),
    );
  }

  Future<void> _onNextQuranMushafImagePage(
    NextQuranMushafImagePage event,
    Emitter<QuranMushafImageState> emit,
  ) async {
    final currentState = state;

    if (currentState is! QuranMushafImageLoaded) return;

    final nextPage = _normalizePage(currentState.currentPage + 1);

    if (nextPage == currentState.currentPage) return;

    add(ChangeQuranMushafImagePage(nextPage));
  }

  Future<void> _onPreviousQuranMushafImagePage(
    PreviousQuranMushafImagePage event,
    Emitter<QuranMushafImageState> emit,
  ) async {
    final currentState = state;

    if (currentState is! QuranMushafImageLoaded) return;

    final previousPage = _normalizePage(currentState.currentPage - 1);

    if (previousPage == currentState.currentPage) return;

    add(ChangeQuranMushafImagePage(previousPage));
  }

  Future<void> _onRefreshQuranMushafImagePage(
    RefreshQuranMushafImagePage event,
    Emitter<QuranMushafImageState> emit,
  ) async {
    final currentState = state;

    if (currentState is QuranMushafImageLoaded) {
      add(
        FetchQuranMushafImage(
          currentState.mushaf.id,
          initialPage: currentState.currentPage,
        ),
      );
    }
  }

  List<QuranAyahModel> _getAllAyahs(QuranMushafModel mushaf) {
    return mushaf.surahs.expand((surah) => surah.ayahs).toList();
  }

  List<QuranAyahModel> _getAyahsByPage(List<QuranAyahModel> ayahs, int page) {
    return ayahs.where((ayah) => ayah.pageNumber == page).toList();
  }

  int? _getCurrentJuz(List<QuranAyahModel> ayahs) {
    if (ayahs.isEmpty) return null;
    return ayahs.first.juz;
  }

  String _getCurrentSurahName(
    QuranMushafModel mushaf,
    List<QuranAyahModel> ayahs,
  ) {
    if (ayahs.isEmpty) return 'Al-Qur\'an';

    final currentSurahNumber = ayahs.first.surah;

    final QuranSurahModel? surah = mushaf.surahs
        .cast<QuranSurahModel?>()
        .firstWhere(
          (item) =>
              item?.surahNumber == currentSurahNumber ||
              item?.id == currentSurahNumber,
          orElse: () => null,
        );

    return surah?.name ?? 'Al-Qur\'an';
  }

  int _normalizePage(int page) {
    if (page < 1) return 1;
    if (page > 604) return 604;
    return page;
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
