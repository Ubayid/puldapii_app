import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/models/new_model.dart';
import 'package:puldapii/utils/services/new/new_service.dart';

part 'new_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsService newsService;

  NewsCubit({required this.newsService}) : super(const NewsState());

  /// Mengambil daftar berita dari halaman pertama.
  ///
  /// Parameter yang tidak dikirim akan menggunakan filter
  /// dan jumlah data dari state saat ini.
  Future<void> fetchNews({
    String? search,
    String? category,
    int? perPage,
  }) async {
    final selectedSearch = search ?? state.search;
    final selectedCategory = category ?? state.category;
    final selectedPerPage = perPage ?? state.perPage;

    emit(
      state.copyWith(
        listStatus: NewsListStatus.loading,
        search: selectedSearch,
        category: selectedCategory,
        perPage: selectedPerPage,
        currentPage: 1,
        clearMessage: true,
      ),
    );

    try {
      final result = await newsService.getNews(
        page: 1,
        perPage: selectedPerPage,
        q: selectedSearch,
        category: selectedCategory,
      );

      emit(
        state.copyWith(
          listStatus: NewsListStatus.success,
          news: result.data,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          perPage: result.perPage,
          total: result.total,
          hasMorePages: result.hasMorePages,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          listStatus: NewsListStatus.failure,
          news: const [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
          hasMorePages: false,
          message: _getErrorMessage(error),
        ),
      );
    }
  }

  /// Refresh daftar berita dengan filter yang sedang aktif.
  Future<void> refreshNews() async {
    try {
      final result = await newsService.getNews(
        page: 1,
        perPage: state.perPage,
        q: state.search,
        category: state.category,
      );

      emit(
        state.copyWith(
          listStatus: NewsListStatus.success,
          news: result.data,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          perPage: result.perPage,
          total: result.total,
          hasMorePages: result.hasMorePages,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          listStatus: NewsListStatus.failure,
          message: _getErrorMessage(error),
        ),
      );
    }
  }

  /// Mengambil halaman berikutnya.
  Future<void> loadMoreNews() async {
    if (state.listStatus == NewsListStatus.loading ||
        state.listStatus == NewsListStatus.loadingMore ||
        !state.hasMorePages) {
      return;
    }

    final nextPage = state.currentPage + 1;

    if (nextPage > state.lastPage) {
      emit(state.copyWith(hasMorePages: false));

      return;
    }

    emit(
      state.copyWith(
        listStatus: NewsListStatus.loadingMore,
        clearMessage: true,
      ),
    );

    try {
      final result = await newsService.getNews(
        page: nextPage,
        perPage: state.perPage,
        q: state.search,
        category: state.category,
      );

      final combinedNews = <NewsModel>[...state.news, ...result.data];

      // Menghindari data berita ganda berdasarkan ID.
      final uniqueNews = <int, NewsModel>{};

      for (final item in combinedNews) {
        uniqueNews[item.id] = item;
      }

      emit(
        state.copyWith(
          listStatus: NewsListStatus.success,
          news: uniqueNews.values.toList(),
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          perPage: result.perPage,
          total: result.total,
          hasMorePages: result.hasMorePages,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          listStatus: NewsListStatus.failure,
          message: _getErrorMessage(error),
        ),
      );
    }
  }

  /// Melakukan pencarian berita.
  Future<void> searchNews(String value) async {
    await fetchNews(search: value.trim());
  }

  /// Melakukan filter berdasarkan kategori.
  ///
  /// Nilai kategori:
  /// - Semua
  /// - Berita
  /// - Info
  Future<void> filterByCategory(String category) async {
    await fetchNews(category: category);
  }

  /// Mengubah pencarian dan kategori secara bersamaan.
  Future<void> applyFilter({
    required String search,
    required String category,
  }) async {
    await fetchNews(search: search.trim(), category: category);
  }

  /// Menghapus pencarian dan filter kategori.
  Future<void> resetFilter() async {
    await fetchNews(search: '', category: 'Semua');
  }

  /// Mengambil detail berita.
  Future<void> fetchNewsDetail(int id) async {
    emit(
      state.copyWith(
        detailStatus: NewsDetailStatus.loading,
        clearSelectedNews: true,
        clearDetailMessage: true,
      ),
    );

    try {
      final result = await newsService.getNewsDetail(id);

      emit(
        state.copyWith(
          detailStatus: NewsDetailStatus.success,
          selectedNews: result,
          clearDetailMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          detailStatus: NewsDetailStatus.failure,
          detailMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  /// Menghapus data detail ketika keluar dari halaman detail.
  void clearNewsDetail() {
    emit(
      state.copyWith(
        detailStatus: NewsDetailStatus.initial,
        clearSelectedNews: true,
        clearDetailMessage: true,
      ),
    );
  }

  /// Menghapus pesan error daftar berita.
  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  String _getErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> fetchNewsPage(int page) async {
    if (page < 1) {
      return;
    }

    if (state.listStatus == NewsListStatus.loading ||
        state.listStatus == NewsListStatus.loadingMore) {
      return;
    }

    if (state.lastPage > 0 && page > state.lastPage) {
      return;
    }

    emit(
      state.copyWith(listStatus: NewsListStatus.loading, clearMessage: true),
    );

    try {
      final result = await newsService.getNews(
        page: page,
        perPage: state.perPage,
        q: state.search,
        category: state.category,
      );

      emit(
        state.copyWith(
          listStatus: NewsListStatus.success,
          news: result.data,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          perPage: result.perPage,
          total: result.total,
          hasMorePages: result.hasMorePages,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          listStatus: NewsListStatus.failure,
          message: _getErrorMessage(error),
        ),
      );
    }
  }
}
