part of 'hadist_detail_bloc.dart';

@immutable
sealed class HadistDetailState {}

final class HadistDetailInitial extends HadistDetailState {}

final class HadistDetailLoading extends HadistDetailState {}

final class HadistDetailLoaded extends HadistDetailState {
  final String book;
  final HadistModel hadist;

  HadistDetailLoaded({required this.book, required this.hadist});
}

final class HadistDetailError extends HadistDetailState {
  final String message;

  HadistDetailError(this.message);
}
