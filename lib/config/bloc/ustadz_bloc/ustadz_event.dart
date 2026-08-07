part of 'ustadz_bloc.dart';

@immutable
sealed class UstadzEvent {}

final class FetchUstadzList extends UstadzEvent {
  final int page;
  final int perPage;

  FetchUstadzList({this.page = 1, this.perPage = 100});
}

final class FetchUstadzDetail extends UstadzEvent {
  final int id;

  FetchUstadzDetail(this.id);
}

final class FetchUstadzDetailByCode extends UstadzEvent {
  final String code;

  FetchUstadzDetailByCode(this.code);
}

final class UpdateUstadzSearch extends UstadzEvent {
  final String query;

  UpdateUstadzSearch(this.query);
}

final class UpdateUstadzStatusFilter extends UstadzEvent {
  final int selectedStatusIndex;

  UpdateUstadzStatusFilter(this.selectedStatusIndex);
}

final class ChangeUstadzPage extends UstadzEvent {
  final int page;

  ChangeUstadzPage(this.page);
}

final class UpdateUstadzExpertiseFilter extends UstadzEvent {
  final Set<int> selectedExpertiseIds;

  UpdateUstadzExpertiseFilter(this.selectedExpertiseIds);
}

final class RemoveUstadzExpertiseFilter extends UstadzEvent {
  final int expertiseId;

  RemoveUstadzExpertiseFilter(this.expertiseId);
}
