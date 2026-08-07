import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:puldapii/models/dzikir_pp_model.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/utils/services/home/dzikir_pp_service.dart';

part 'dzikir_pp_event.dart';
part 'dzikir_pp_state.dart';

enum DzikirPpCategory { pagi, petang }

extension DzikirPpCategoryX on DzikirPpCategory {
  String get value {
    switch (this) {
      case DzikirPpCategory.pagi:
        return 'pagi';
      case DzikirPpCategory.petang:
        return 'petang';
    }
  }

  String get label {
    switch (this) {
      case DzikirPpCategory.pagi:
        return 'Dzikir Pagi';
      case DzikirPpCategory.petang:
        return 'Dzikir Petang';
    }
  }
}

class DzikirPpBloc extends Bloc<DzikirPpEvent, DzikirPpState> {
  final DzikirPpService service;
  final DzikirPpCategory category;

  DzikirPpBloc(this.service, {required this.category})
    : super(DzikirPpState.initial(category)) {
    on<FetchDzikirPp>(_onFetchDzikirPp);
    on<ChangeDzikirPpPage>(_onChangeDzikirPpPage);
    on<RefreshDzikirPp>(_onRefreshDzikirPp);
  }

  Future<void> _onFetchDzikirPp(
    FetchDzikirPp event,
    Emitter<DzikirPpState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await service.getDzikirPaginated(
        waktu: category.value,
        page: event.page,
        perPage: 1,
      );

      emit(
        state.copyWith(isLoading: false, paginated: result, clearError: true),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _cleanError(e)));
    }
  }

  Future<void> _onChangeDzikirPpPage(
    ChangeDzikirPpPage event,
    Emitter<DzikirPpState> emit,
  ) async {
    add(FetchDzikirPp(page: event.page));
  }

  Future<void> _onRefreshDzikirPp(
    RefreshDzikirPp event,
    Emitter<DzikirPpState> emit,
  ) async {
    add(FetchDzikirPp(page: state.page));
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
