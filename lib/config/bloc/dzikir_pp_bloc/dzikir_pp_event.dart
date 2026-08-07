part of 'dzikir_pp_bloc.dart';

@immutable
sealed class DzikirPpEvent {}

final class FetchDzikirPp extends DzikirPpEvent {
  final int page;

  FetchDzikirPp({this.page = 1});
}

final class ChangeDzikirPpPage extends DzikirPpEvent {
  final int page;

  ChangeDzikirPpPage(this.page);
}

final class RefreshDzikirPp extends DzikirPpEvent {}
