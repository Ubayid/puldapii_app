part of 'kajian_bloc.dart';

@immutable
class KajianState {
  final bool isLoading;
  final String? errorMessage;

  final List<DakwahModel> rawItems;
  final List<DakwahModel> filteredItems;
  final List<DakwahTagOption> tagOptions;

  final String searchQuery;
  final int selectedFilter;
  final Set<int> selectedTagIds;
  final Position? userPosition;

  final int page;
  final int perPage;
  final bool hasNextPage;
  final int lastPage;
  final int total;

  const KajianState({
    this.isLoading = false,
    this.errorMessage,
    this.rawItems = const [],
    this.filteredItems = const [],
    this.tagOptions = const [],
    this.searchQuery = '',
    this.selectedFilter = 0,
    this.selectedTagIds = const {},
    this.userPosition,
    this.page = 1,
    this.perPage = 5,
    this.hasNextPage = false,
    this.lastPage = 1,
    this.total = 0,
  });

  KajianState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DakwahModel>? rawItems,
    List<DakwahModel>? filteredItems,
    List<DakwahTagOption>? tagOptions,
    String? searchQuery,
    int? selectedFilter,
    Set<int>? selectedTagIds,
    Position? userPosition,
    int? page,
    int? perPage,
    bool? hasNextPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return KajianState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rawItems: rawItems ?? this.rawItems,
      filteredItems: filteredItems ?? this.filteredItems,
      tagOptions: tagOptions ?? this.tagOptions,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      userPosition: userPosition ?? this.userPosition,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

final class KajianInitial extends KajianState {}
