part of 'new_cubit.dart';

enum NewsListStatus { initial, loading, success, loadingMore, failure }

enum NewsDetailStatus { initial, loading, success, failure }

class NewsState extends Equatable {
  final NewsListStatus listStatus;
  final NewsDetailStatus detailStatus;

  final List<NewsModel> news;
  final NewsModel? selectedNews;

  final String search;
  final String category;

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  final String? message;
  final String? detailMessage;

  const NewsState({
    this.listStatus = NewsListStatus.initial,
    this.detailStatus = NewsDetailStatus.initial,
    this.news = const [],
    this.selectedNews,
    this.search = '',
    this.category = 'Semua',
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.hasMorePages = false,
    this.message,
    this.detailMessage,
  });

  NewsState copyWith({
    NewsListStatus? listStatus,
    NewsDetailStatus? detailStatus,
    List<NewsModel>? news,
    NewsModel? selectedNews,
    String? search,
    String? category,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    bool? hasMorePages,
    String? message,
    String? detailMessage,
    bool clearMessage = false,
    bool clearDetailMessage = false,
    bool clearSelectedNews = false,
  }) {
    return NewsState(
      listStatus: listStatus ?? this.listStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      news: news ?? this.news,
      selectedNews: clearSelectedNews
          ? null
          : selectedNews ?? this.selectedNews,
      search: search ?? this.search,
      category: category ?? this.category,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      message: clearMessage ? null : message ?? this.message,
      detailMessage: clearDetailMessage
          ? null
          : detailMessage ?? this.detailMessage,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    detailStatus,
    news,
    selectedNews,
    search,
    category,
    currentPage,
    lastPage,
    perPage,
    total,
    hasMorePages,
    message,
    detailMessage,
  ];
}
