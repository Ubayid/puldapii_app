part of 'kajian_bloc.dart';

@immutable
sealed class KajianEvent {}

final class FetchKajianData extends KajianEvent {
  final int page;
  final int perPage;

  FetchKajianData({this.page = 1, this.perPage = 5});
}

final class RefreshKajianData extends KajianEvent {}

final class ChangeKajianPage extends KajianEvent {
  final int page;

  ChangeKajianPage(this.page);
}

final class UpdateKajianSearch extends KajianEvent {
  final String query;

  UpdateKajianSearch(this.query);
}

final class UpdateKajianMainFilter extends KajianEvent {
  final int selectedFilter;

  UpdateKajianMainFilter(this.selectedFilter);
}

final class UpdateKajianTags extends KajianEvent {
  final Set<int> selectedTagIds;

  UpdateKajianTags(this.selectedTagIds);
}

final class RemoveKajianTag extends KajianEvent {
  final int tagId;

  RemoveKajianTag(this.tagId);
}
