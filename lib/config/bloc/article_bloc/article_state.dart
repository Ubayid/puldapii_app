part of 'article_bloc.dart';

@immutable
sealed class ArticleState {
  const ArticleState();
}

final class ArticleInitial extends ArticleState {
  const ArticleInitial();
}

final class ArticleLoaded extends ArticleState {
  final List<FilterOption> categoryOptions;
  final List<ArticleModel> articles;
  final Set<int> selectedCategoryIds;
  final String searchQuery;

  final int page;
  final int perPage;

  final bool isLoading;
  final bool hasNextPage;
  final bool showPager;

  final String? error;

  const ArticleLoaded({
    this.categoryOptions = const [],
    this.articles = const [],
    this.selectedCategoryIds = const {},
    this.searchQuery = '',
    this.page = 1,
    this.perPage = 5,
    this.isLoading = false,
    this.hasNextPage = false,
    this.showPager = false,
    this.error,
  });

  ArticleLoaded copyWith({
    List<FilterOption>? categoryOptions,
    List<ArticleModel>? articles,
    Set<int>? selectedCategoryIds,
    String? searchQuery,
    int? page,
    int? perPage,
    bool? isLoading,
    bool? hasNextPage,
    bool? showPager,
    String? error,
  }) {
    return ArticleLoaded(
      categoryOptions: categoryOptions ?? this.categoryOptions,
      articles: articles ?? this.articles,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      showPager: showPager ?? this.showPager,
      error: error,
    );
  }
}
