part of 'hadist_detail_bloc.dart';

@immutable
sealed class HadistDetailEvent {}

final class FetchHadistDetail extends HadistDetailEvent {
  final String book;
  final int id;

  FetchHadistDetail({required this.book, required this.id});
}
