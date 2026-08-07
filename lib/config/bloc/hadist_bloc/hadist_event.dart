part of 'hadist_bloc.dart';

@immutable
sealed class HadistEvent {}

final class FetchHadistBooks extends HadistEvent {
  final int perPage;

  FetchHadistBooks({this.perPage = 20});
}

final class FetchHadistList extends HadistEvent {
  final String book;
  final int page;
  final int perPage;
  final String query;

  FetchHadistList({
    required this.book,
    this.page = 1,
    this.perPage = 20,
    this.query = '',
  });
}

final class ChangeHadistBook extends HadistEvent {
  final String book;

  ChangeHadistBook(this.book);
}

final class UpdateHadistSearch extends HadistEvent {
  final String query;

  UpdateHadistSearch(this.query);
}

final class ChangeHadistPage extends HadistEvent {
  final int page;

  ChangeHadistPage(this.page);
}
