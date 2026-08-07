part of 'quran_mushaf_bloc.dart';

@immutable
abstract class QuranMushafState {}

class QuranMushafInitial extends QuranMushafState {}

class QuranMushafLoading extends QuranMushafState {}

class MushafsLoaded extends QuranMushafState {
  final List<QuranMushafModel> mushafs;

  MushafsLoaded(this.mushafs);
}

class QuranMushafError extends QuranMushafState {
  final String message;

  QuranMushafError(this.message);
}

class MushafPageSegment {
  final int surahNumber;
  final String surahName;
  final String arabicText;
  final bool showDivider;
  final bool showBismillah;

  const MushafPageSegment({
    required this.surahNumber,
    required this.surahName,
    required this.arabicText,
    required this.showDivider,
    required this.showBismillah,
  });
}

class MushafDetailLoaded extends QuranMushafState {
  final QuranMushafModel mushaf;
  final int currentPage;
  final int totalPages;
  final List<QuranAyahModel> currentPageAyahs;
  final Map<int, List<QuranAyahModel>> groupedPages;

  final String currentSurahName;
  final int? currentJuz;
  final int ayahCount;
  final bool showTopBismillah;
  final List<MushafPageSegment> segments;

  MushafDetailLoaded({
    required this.mushaf,
    required this.currentPage,
    required this.totalPages,
    required this.currentPageAyahs,
    required this.groupedPages,
    required this.currentSurahName,
    required this.currentJuz,
    required this.ayahCount,
    required this.showTopBismillah,
    required this.segments,
  });

  MushafDetailLoaded copyWith({
    QuranMushafModel? mushaf,
    int? currentPage,
    int? totalPages,
    List<QuranAyahModel>? currentPageAyahs,
    Map<int, List<QuranAyahModel>>? groupedPages,
    String? currentSurahName,
    int? currentJuz,
    int? ayahCount,
    bool? showTopBismillah,
    List<MushafPageSegment>? segments,
  }) {
    return MushafDetailLoaded(
      mushaf: mushaf ?? this.mushaf,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentPageAyahs: currentPageAyahs ?? this.currentPageAyahs,
      groupedPages: groupedPages ?? this.groupedPages,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      currentJuz: currentJuz ?? this.currentJuz,
      ayahCount: ayahCount ?? this.ayahCount,
      showTopBismillah: showTopBismillah ?? this.showTopBismillah,
      segments: segments ?? this.segments,
    );
  }
}
