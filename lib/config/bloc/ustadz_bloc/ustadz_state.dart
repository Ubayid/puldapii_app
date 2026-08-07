part of 'ustadz_bloc.dart';

@immutable
sealed class UstadzState {}

final class UstadzInitial extends UstadzState {}

final class UstadzLoading extends UstadzState {}

final class UstadzError extends UstadzState {
  final String message;

  UstadzError(this.message);
}

final class UstadzDetailLoaded extends UstadzState {
  final UstadzModel result;

  UstadzDetailLoaded(this.result);
}

final class UstadzListLoaded extends UstadzState {
  final Paginated<UstadzModel> result;
  final List<UstadzModel> filteredItems;
  final List<UstadzModel> pagedItems;

  final String searchQuery;
  final int selectedStatusIndex;
  final int currentPage;
  final int itemsPerPage;
  final int totalPages;
  final bool hasNextPage;

  final Set<int> selectedExpertiseIds;
  final List<FilterOption> expertiseOptions;

  UstadzListLoaded({
    required this.result,
    required this.filteredItems,
    required this.pagedItems,
    required this.searchQuery,
    required this.selectedStatusIndex,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.selectedExpertiseIds,
    required this.expertiseOptions,
  });

  UstadzListLoaded copyWith({
    Paginated<UstadzModel>? result,
    List<UstadzModel>? filteredItems,
    List<UstadzModel>? pagedItems,
    String? searchQuery,
    int? selectedStatusIndex,
    int? currentPage,
    int? itemsPerPage,
    int? totalPages,
    bool? hasNextPage,
    Set<int>? selectedExpertiseIds,
    List<FilterOption>? expertiseOptions,
  }) {
    return UstadzListLoaded(
      result: result ?? this.result,
      filteredItems: filteredItems ?? this.filteredItems,
      pagedItems: pagedItems ?? this.pagedItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusIndex: selectedStatusIndex ?? this.selectedStatusIndex,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      selectedExpertiseIds: selectedExpertiseIds ?? this.selectedExpertiseIds,
      expertiseOptions: expertiseOptions ?? this.expertiseOptions,
    );
  }
}
