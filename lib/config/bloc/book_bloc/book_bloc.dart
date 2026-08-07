import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puldapii/models/book_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:puldapii/utils/services/home/book_service.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookService bookService;

  BookBloc(this.bookService) : super(BookInitial()) {
    on<FetchBookCategories>(_onFetchBookCategories);
    on<FetchBooks>(_onFetchBooks);
    on<FetchFeaturedBooks>(_onFetchFeaturedBooks);
    on<FetchBookDetail>(_onFetchBookDetail);
  }

  Future<void> _onFetchBookCategories(
    FetchBookCategories event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    try {
      final categories = await bookService.getBookCategories();
      emit(BookCategoriesLoaded(categories));
    } catch (e) {
      emit(BookError(_errorMessage(e)));
    }
  }

  Future<void> _onFetchBooks(FetchBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());

    try {
      final books = await bookService.getBooks(
        search: event.search,
        bookCategoryId: event.bookCategoryId,
        categorySlug: event.categorySlug,
        page: event.page,
        perPage: event.perPage,
      );

      emit(BooksLoaded(books));
    } catch (e) {
      emit(BookError(_errorMessage(e)));
    }
  }

  Future<void> _onFetchFeaturedBooks(
    FetchFeaturedBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    try {
      final books = await bookService.getFeaturedBooks();
      emit(FeaturedBooksLoaded(books));
    } catch (e) {
      emit(BookError(_errorMessage(e)));
    }
  }

  Future<void> _onFetchBookDetail(
    FetchBookDetail event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    try {
      final book = await bookService.getBookDetail(event.idOrSlug);
      emit(BookDetailLoaded(book));
    } catch (e) {
      emit(BookError(_errorMessage(e)));
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiFailure) {
      return error.message;
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
