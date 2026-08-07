part of 'dzikir_pp_bloc.dart';

@immutable
class DzikirPpState {
  final DzikirPpCategory category;
  final bool isLoading;
  final String? errorMessage;
  final Paginated<DzikirPpModel>? paginated;

  const DzikirPpState({
    required this.category,
    required this.isLoading,
    this.errorMessage,
    this.paginated,
  });

  factory DzikirPpState.initial(DzikirPpCategory category) {
    return DzikirPpState(
      category: category,
      isLoading: false,
      errorMessage: null,
      paginated: null,
    );
  }

  DzikirPpState copyWith({
    DzikirPpCategory? category,
    bool? isLoading,
    String? errorMessage,
    Paginated<DzikirPpModel>? paginated,
    bool clearError = false,
  }) {
    return DzikirPpState(
      category: category ?? this.category,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      paginated: paginated ?? this.paginated,
    );
  }

  int get page => paginated?.currentPage ?? 1;

  bool get hasNextPage {
    final current = paginated?.currentPage ?? 1;
    final last = paginated?.lastPage ?? 1;
    return current < last;
  }

  DzikirPpModel? get currentItem {
    final items = paginated?.items ?? [];
    if (items.isEmpty) return null;
    return items.first;
  }

  bool get isEmpty => (paginated?.items ?? []).isEmpty;
}
