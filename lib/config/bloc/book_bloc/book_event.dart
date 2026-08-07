part of 'book_bloc.dart';

abstract class BookEvent {}

class FetchBookCategories extends BookEvent {}

class FetchBooks extends BookEvent {
  final String? search;
  final int? bookCategoryId;
  final String? categorySlug;
  final int page;
  final int perPage;

  FetchBooks({
    this.search,
    this.bookCategoryId,
    this.categorySlug,
    this.page = 1,
    this.perPage = 10,
  });
}

class FetchFeaturedBooks extends BookEvent {}

class FetchBookDetail extends BookEvent {
  final String idOrSlug;

  FetchBookDetail(this.idOrSlug);
}
