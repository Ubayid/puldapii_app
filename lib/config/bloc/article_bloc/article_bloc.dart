import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:puldapii/models/article_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:puldapii/utils/services/article/article_service.dart';
import 'package:puldapii/utils/widget/widget_filter_all.dart';

part 'article_event.dart';
part 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleService service;

  ArticleBloc({required this.service}) : super(const ArticleInitial()) {
    on<ArticleInitialized>(_onInitialized);
    on<ArticleFetched>(_onFetched);
    on<ArticleSearchChanged>(_onSearchChanged);
    on<ArticleSearchCleared>(_onSearchCleared);
    on<ArticleCategoriesApplied>(_onCategoriesApplied);
    on<ArticleCategoryRemoved>(_onCategoryRemoved);
    on<ArticlePagerToggled>(_onPagerToggled);
    on<ArticleRefreshed>(_onRefreshed);
  }

  Future<void> _onInitialized(
    ArticleInitialized event,
    Emitter<ArticleState> emit,
  ) async {
    final initialIds = <int>{...?event.initialCategoryIds};

    emit(ArticleLoaded(selectedCategoryIds: initialIds, isLoading: true));

    try {
      final categories = await service.fetchCategories();
      final options = categories
          .map((e) => FilterOption(id: e.id, name: e.name))
          .toList();

      final articles = await service.fetchPostList(
        categoryIds: initialIds.isEmpty ? null : initialIds.toList(),
        perPage: 5,
        page: 1,
        search: '',
      );

      emit(
        ArticleLoaded(
          categoryOptions: options,
          articles: articles,
          selectedCategoryIds: initialIds,
          searchQuery: '',
          page: 1,
          perPage: 5,
          isLoading: false,
          hasNextPage: articles.length == 5,
          showPager: false,
        ),
      );
    } catch (e) {
      emit(
        ArticleLoaded(
          selectedCategoryIds: initialIds,
          isLoading: false,
          error: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onFetched(
    ArticleFetched event,
    Emitter<ArticleState> emit,
  ) async {
    final current = _currentState;

    emit(current.copyWith(isLoading: true, error: null));

    try {
      final result = await service.fetchPostList(
        categoryIds: current.selectedCategoryIds.isEmpty
            ? null
            : current.selectedCategoryIds.toList(),
        perPage: current.perPage,
        page: event.page,
        search: current.searchQuery,
      );

      emit(
        current.copyWith(
          isLoading: false,
          articles: result,
          page: event.page,
          hasNextPage: result.length == current.perPage,
          error: null,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoading: false, error: _errorMessage(e)));
    }
  }

  Future<void> _onSearchChanged(
    ArticleSearchChanged event,
    Emitter<ArticleState> emit,
  ) async {
    final current = _currentState;

    emit(
      current.copyWith(
        isLoading: true,
        searchQuery: event.query,
        page: 1,
        error: null,
      ),
    );

    try {
      final result = await service.fetchPostList(
        categoryIds: current.selectedCategoryIds.isEmpty
            ? null
            : current.selectedCategoryIds.toList(),
        perPage: current.perPage,
        page: 1,
        search: event.query,
      );

      emit(
        current.copyWith(
          isLoading: false,
          searchQuery: event.query,
          articles: result,
          page: 1,
          hasNextPage: result.length == current.perPage,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          searchQuery: event.query,
          error: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onSearchCleared(
    ArticleSearchCleared event,
    Emitter<ArticleState> emit,
  ) async {
    final current = _currentState;

    emit(
      current.copyWith(isLoading: true, searchQuery: '', page: 1, error: null),
    );

    try {
      final result = await service.fetchPostList(
        categoryIds: current.selectedCategoryIds.isEmpty
            ? null
            : current.selectedCategoryIds.toList(),
        perPage: current.perPage,
        page: 1,
        search: '',
      );

      emit(
        current.copyWith(
          isLoading: false,
          searchQuery: '',
          articles: result,
          page: 1,
          hasNextPage: result.length == current.perPage,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          searchQuery: '',
          error: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onCategoriesApplied(
    ArticleCategoriesApplied event,
    Emitter<ArticleState> emit,
  ) async {
    final current = _currentState;
    final selectedIds = Set<int>.from(event.selectedIds);

    emit(
      current.copyWith(
        isLoading: true,
        selectedCategoryIds: selectedIds,
        page: 1,
        error: null,
      ),
    );

    try {
      final result = await service.fetchPostList(
        categoryIds: selectedIds.isEmpty ? null : selectedIds.toList(),
        perPage: current.perPage,
        page: 1,
        search: current.searchQuery,
      );

      emit(
        current.copyWith(
          isLoading: false,
          selectedCategoryIds: selectedIds,
          articles: result,
          page: 1,
          hasNextPage: result.length == current.perPage,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          selectedCategoryIds: selectedIds,
          error: _errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onCategoryRemoved(
    ArticleCategoryRemoved event,
    Emitter<ArticleState> emit,
  ) async {
    final current = _currentState;
    final selectedIds = Set<int>.from(current.selectedCategoryIds)
      ..remove(event.id);

    emit(
      current.copyWith(
        isLoading: true,
        selectedCategoryIds: selectedIds,
        page: 1,
        error: null,
      ),
    );

    try {
      final result = await service.fetchPostList(
        categoryIds: selectedIds.isEmpty ? null : selectedIds.toList(),
        perPage: current.perPage,
        page: 1,
        search: current.searchQuery,
      );

      emit(
        current.copyWith(
          isLoading: false,
          selectedCategoryIds: selectedIds,
          articles: result,
          page: 1,
          hasNextPage: result.length == current.perPage,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          selectedCategoryIds: selectedIds,
          error: _errorMessage(e),
        ),
      );
    }
  }

  void _onPagerToggled(ArticlePagerToggled event, Emitter<ArticleState> emit) {
    final current = _currentState;
    emit(current.copyWith(showPager: !current.showPager));
  }

  Future<void> _onRefreshed(
    ArticleRefreshed event,
    Emitter<ArticleState> emit,
  ) async {
    final current = _currentState;

    emit(current.copyWith(isLoading: true, error: null));

    try {
      final result = await service.fetchPostList(
        categoryIds: current.selectedCategoryIds.isEmpty
            ? null
            : current.selectedCategoryIds.toList(),
        perPage: current.perPage,
        page: current.page,
        search: current.searchQuery,
      );

      emit(
        current.copyWith(
          isLoading: false,
          articles: result,
          hasNextPage: result.length == current.perPage,
          error: null,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoading: false, error: _errorMessage(e)));
    }
  }

  ArticleLoaded get _currentState {
    if (state is ArticleLoaded) {
      return state as ArticleLoaded;
    }

    return const ArticleLoaded();
  }
}

String _errorMessage(Object error) {
  if (error is ApiFailure) {
    return error.message;
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
