part of 'book_bloc.dart';

abstract class BookState {}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookCategoriesLoaded extends BookState {
  final List<BookCategoryModel> categories;

  BookCategoriesLoaded(this.categories);
}

class BooksLoaded extends BookState {
  final List<BookModel> books;

  BooksLoaded(this.books);
}

class FeaturedBooksLoaded extends BookState {
  final List<BookModel> books;

  FeaturedBooksLoaded(this.books);
}

class BookDetailLoaded extends BookState {
  final BookModel book;

  BookDetailLoaded(this.book);
}

class BookError extends BookState {
  final String message;

  BookError(this.message);
}
