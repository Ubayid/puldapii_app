part of 'quran_mushaf_bloc.dart';

@immutable
abstract class QuranMushafEvent {}

class FetchMushafs extends QuranMushafEvent {}

class FetchMushafDetail extends QuranMushafEvent {
  final int mushafId;
  final int initialPage;

  FetchMushafDetail(this.mushafId, {this.initialPage = 1});
}

class ChangeMushafPage extends QuranMushafEvent {
  final int pageNumber;

  ChangeMushafPage(this.pageNumber);
}

class NextMushafPage extends QuranMushafEvent {}

class PreviousMushafPage extends QuranMushafEvent {}
