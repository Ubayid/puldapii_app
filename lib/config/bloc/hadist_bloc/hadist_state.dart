part of 'hadist_bloc.dart';

@immutable
sealed class HadistState {}

final class HadistInitial extends HadistState {}

final class HadistLoading extends HadistState {}

final class HadistError extends HadistState {
  final String message;

  HadistError(this.message);
}

final class HadistLoaded extends HadistState {
  final List<String> books;
  final String selectedBook;
  final Paginated<HadistModel> data;
  final String query;

  HadistLoaded({
    required this.books,
    required this.selectedBook,
    required this.data,
    required this.query,
  });
}
