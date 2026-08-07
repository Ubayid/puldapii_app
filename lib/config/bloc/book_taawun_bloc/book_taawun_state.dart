part of 'book_taawun_bloc.dart';

final class BookTaawunState extends Equatable {
  final List<BookTaawunModel> taawuns;
  final List<BookTaawunBookModel> activeBooks;
  final BookTaawunModel? selectedTaawun;

  final bool isLoading;
  final bool isBooksLoading;
  final bool isDetailLoading;
  final bool isSubmitting;

  final String statusFilter;
  final String search;

  final int page;
  final int perPage;
  final int lastPage;
  final int total;
  final int? from;
  final int? to;

  final String? errorMessage;
  final String? successMessage;

  const BookTaawunState({
    this.taawuns = const [],
    this.activeBooks = const [],
    this.selectedTaawun,
    this.isLoading = false,
    this.isBooksLoading = false,
    this.isDetailLoading = false,
    this.isSubmitting = false,
    this.statusFilter = '',
    this.search = '',
    this.page = 1,
    this.perPage = 10,
    this.lastPage = 1,
    this.total = 0,
    this.from,
    this.to,
    this.errorMessage,
    this.successMessage,
  });

  bool get hasNextPage => page < lastPage;

  bool get hasPreviousPage => page > 1;

  bool get isEmpty => !isLoading && taawuns.isEmpty;

  BookTaawunState copyWith({
    List<BookTaawunModel>? taawuns,
    List<BookTaawunBookModel>? activeBooks,
    BookTaawunModel? selectedTaawun,
    bool clearSelectedTaawun = false,
    bool? isLoading,
    bool? isBooksLoading,
    bool? isDetailLoading,
    bool? isSubmitting,
    String? statusFilter,
    String? search,
    int? page,
    int? perPage,
    int? lastPage,
    int? total,
    int? from,
    int? to,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return BookTaawunState(
      taawuns: taawuns ?? this.taawuns,
      activeBooks: activeBooks ?? this.activeBooks,
      selectedTaawun: clearSelectedTaawun
          ? null
          : selectedTaawun ?? this.selectedTaawun,
      isLoading: isLoading ?? this.isLoading,
      isBooksLoading: isBooksLoading ?? this.isBooksLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      statusFilter: statusFilter ?? this.statusFilter,
      search: search ?? this.search,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      from: clearFrom ? null : from ?? this.from,
      to: clearTo ? null : to ?? this.to,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    taawuns,
    activeBooks,
    selectedTaawun,
    isLoading,
    isBooksLoading,
    isDetailLoading,
    isSubmitting,
    statusFilter,
    search,
    page,
    perPage,
    lastPage,
    total,
    from,
    to,
    errorMessage,
    successMessage,
  ];
}
