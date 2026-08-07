part of 'quran_mushaf_image_bloc.dart';

@immutable
abstract class QuranMushafImageEvent {}

class FetchQuranMushafImage extends QuranMushafImageEvent {
  final int mushafId;
  final int initialPage;

  FetchQuranMushafImage(this.mushafId, {this.initialPage = 1});
}

class ChangeQuranMushafImagePage extends QuranMushafImageEvent {
  final int page;

  ChangeQuranMushafImagePage(this.page);
}

class NextQuranMushafImagePage extends QuranMushafImageEvent {}

class PreviousQuranMushafImagePage extends QuranMushafImageEvent {}

class RefreshQuranMushafImagePage extends QuranMushafImageEvent {}
