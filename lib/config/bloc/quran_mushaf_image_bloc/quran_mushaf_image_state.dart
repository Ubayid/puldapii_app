part of 'quran_mushaf_image_bloc.dart';

@immutable
abstract class QuranMushafImageState {
  final int currentPage;

  const QuranMushafImageState({this.currentPage = 1});
}

class QuranMushafImageInitial extends QuranMushafImageState {
  const QuranMushafImageInitial() : super(currentPage: 1);
}

class QuranMushafImageLoading extends QuranMushafImageState {
  const QuranMushafImageLoading({required super.currentPage});
}

class QuranMushafImageLoaded extends QuranMushafImageState {
  final QuranMushafModel mushaf;
  final int totalPages;
  final List<QuranAyahModel> currentPageAyahs;
  final int? currentJuz;
  final String currentSurahName;
  final String? imagesPngUrl;

  const QuranMushafImageLoaded({
    required this.mushaf,
    required super.currentPage,
    required this.totalPages,
    required this.currentPageAyahs,
    required this.currentJuz,
    required this.currentSurahName,
    required this.imagesPngUrl,
  });

  QuranMushafImageLoaded copyWith({
    QuranMushafModel? mushaf,
    int? currentPage,
    int? totalPages,
    List<QuranAyahModel>? currentPageAyahs,
    int? currentJuz,
    String? currentSurahName,
    String? imagesPngUrl,
  }) {
    return QuranMushafImageLoaded(
      mushaf: mushaf ?? this.mushaf,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentPageAyahs: currentPageAyahs ?? this.currentPageAyahs,
      currentJuz: currentJuz ?? this.currentJuz,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      imagesPngUrl: imagesPngUrl ?? this.imagesPngUrl,
    );
  }
}

class QuranMushafImageError extends QuranMushafImageState {
  final String message;

  const QuranMushafImageError({
    required super.currentPage,
    required this.message,
  });
}
