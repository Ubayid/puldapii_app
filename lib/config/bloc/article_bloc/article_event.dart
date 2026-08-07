part of 'article_bloc.dart';

@immutable
sealed class ArticleEvent {
  const ArticleEvent();
}

final class ArticleInitialized extends ArticleEvent {
  final List<int>? initialCategoryIds;

  const ArticleInitialized({this.initialCategoryIds});
}

final class ArticleFetched extends ArticleEvent {
  final int page;

  const ArticleFetched({this.page = 1});
}

final class ArticleSearchChanged extends ArticleEvent {
  final String query;

  const ArticleSearchChanged(this.query);
}

final class ArticleSearchCleared extends ArticleEvent {
  const ArticleSearchCleared();
}

final class ArticleCategoriesApplied extends ArticleEvent {
  final Set<int> selectedIds;

  const ArticleCategoriesApplied(this.selectedIds);
}

final class ArticleCategoryRemoved extends ArticleEvent {
  final int id;

  const ArticleCategoryRemoved(this.id);
}

final class ArticlePagerToggled extends ArticleEvent {
  const ArticlePagerToggled();
}

final class ArticleRefreshed extends ArticleEvent {
  const ArticleRefreshed();
}
