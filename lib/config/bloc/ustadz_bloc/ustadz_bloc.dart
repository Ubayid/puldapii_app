import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/models/ustadz_model.dart';
import 'package:puldapii/utils/services/home/ustadz_service.dart';
import 'package:puldapii/utils/widget/widget_filter_all.dart';

part 'ustadz_event.dart';
part 'ustadz_state.dart';

class UstadzBloc extends Bloc<UstadzEvent, UstadzState> {
  final UstadzService service;
  final Set<String> allowedRoleSlugs;

  static const int _itemsPerPage = 5;

  UstadzBloc(this.service, {required List<String> roleSlugs})
    : allowedRoleSlugs = roleSlugs.map((e) => e.toLowerCase().trim()).toSet(),
      super(UstadzInitial()) {
    on<FetchUstadzList>(_onFetchUstadzList);
    on<FetchUstadzDetail>(_onFetchUstadzDetail);
    on<FetchUstadzDetailByCode>(_onFetchUstadzDetailByCode);
    on<UpdateUstadzSearch>(_onUpdateUstadzSearch);
    on<UpdateUstadzStatusFilter>(_onUpdateUstadzStatusFilter);
    on<ChangeUstadzPage>(_onChangeUstadzPage);
    on<UpdateUstadzExpertiseFilter>(_onUpdateUstadzExpertiseFilter);
    on<RemoveUstadzExpertiseFilter>(_onRemoveUstadzExpertiseFilter);
  }

  Future<void> _onFetchUstadzList(
    FetchUstadzList event,
    Emitter<UstadzState> emit,
  ) async {
    emit(UstadzLoading());

    try {
      final result = await service.getUstadzList(
        page: event.page,
        perPage: event.perPage,
      );

      final loadedState = _buildListState(
        result: result,
        searchQuery: '',
        selectedStatusIndex: 0,
        selectedExpertiseIds: <int>{},
        currentPage: 1,
      );

      emit(loadedState);
    } catch (e) {
      emit(UstadzError(_cleanError(e)));
    }
  }

  Future<void> _onFetchUstadzDetail(
    FetchUstadzDetail event,
    Emitter<UstadzState> emit,
  ) async {
    emit(UstadzLoading());

    try {
      final result = await service.getUstadzDetail(event.id);
      emit(UstadzDetailLoaded(result));
    } catch (e) {
      emit(UstadzError(_cleanError(e)));
    }
  }

  Future<void> _onFetchUstadzDetailByCode(
    FetchUstadzDetailByCode event,
    Emitter<UstadzState> emit,
  ) async {
    emit(UstadzLoading());

    try {
      final result = await service.getUstadzDetailByCode(event.code);
      emit(UstadzDetailLoaded(result));
    } catch (e) {
      emit(UstadzError(_cleanError(e)));
    }
  }

  void _onUpdateUstadzSearch(
    UpdateUstadzSearch event,
    Emitter<UstadzState> emit,
  ) {
    final currentState = state;

    if (currentState is! UstadzListLoaded) return;

    emit(
      _buildListState(
        result: currentState.result,
        searchQuery: event.query,
        selectedStatusIndex: currentState.selectedStatusIndex,
        selectedExpertiseIds: currentState.selectedExpertiseIds,
        currentPage: 1,
      ),
    );
  }

  void _onUpdateUstadzStatusFilter(
    UpdateUstadzStatusFilter event,
    Emitter<UstadzState> emit,
  ) {
    final currentState = state;

    if (currentState is! UstadzListLoaded) return;

    emit(
      _buildListState(
        result: currentState.result,
        searchQuery: currentState.searchQuery,
        selectedStatusIndex: event.selectedStatusIndex,
        selectedExpertiseIds: currentState.selectedExpertiseIds,
        currentPage: 1,
      ),
    );
  }

  void _onChangeUstadzPage(ChangeUstadzPage event, Emitter<UstadzState> emit) {
    final currentState = state;

    if (currentState is! UstadzListLoaded) return;

    emit(
      _buildListState(
        result: currentState.result,
        searchQuery: currentState.searchQuery,
        selectedStatusIndex: currentState.selectedStatusIndex,
        selectedExpertiseIds: currentState.selectedExpertiseIds,
        currentPage: event.page,
      ),
    );
  }

  void _onUpdateUstadzExpertiseFilter(
    UpdateUstadzExpertiseFilter event,
    Emitter<UstadzState> emit,
  ) {
    final currentState = state;

    if (currentState is! UstadzListLoaded) return;

    emit(
      _buildListState(
        result: currentState.result,
        searchQuery: currentState.searchQuery,
        selectedStatusIndex: currentState.selectedStatusIndex,
        selectedExpertiseIds: event.selectedExpertiseIds,
        currentPage: 1,
      ),
    );
  }

  void _onRemoveUstadzExpertiseFilter(
    RemoveUstadzExpertiseFilter event,
    Emitter<UstadzState> emit,
  ) {
    final currentState = state;

    if (currentState is! UstadzListLoaded) return;

    final newIds = Set<int>.from(currentState.selectedExpertiseIds)
      ..remove(event.expertiseId);

    emit(
      _buildListState(
        result: currentState.result,
        searchQuery: currentState.searchQuery,
        selectedStatusIndex: currentState.selectedStatusIndex,
        selectedExpertiseIds: newIds,
        currentPage: 1,
      ),
    );
  }

  UstadzListLoaded _buildListState({
    required Paginated<UstadzModel> result,
    required String searchQuery,
    required int selectedStatusIndex,
    required Set<int> selectedExpertiseIds,
    required int currentPage,
  }) {
    final expertiseOptions = _buildExpertiseOptions(result.items);

    final filteredItems = _filteredUstadz(
      result.items,
      searchQuery,
      selectedStatusIndex,
      selectedExpertiseIds,
    );

    final totalPages = filteredItems.isEmpty
        ? 1
        : (filteredItems.length / _itemsPerPage).ceil();

    final safePage = currentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage) > filteredItems.length
        ? filteredItems.length
        : (startIndex + _itemsPerPage);

    final pagedItems = filteredItems.isEmpty
        ? <UstadzModel>[]
        : filteredItems.sublist(startIndex, endIndex);

    return UstadzListLoaded(
      result: result,
      filteredItems: filteredItems,
      pagedItems: pagedItems,
      searchQuery: searchQuery,
      selectedStatusIndex: selectedStatusIndex,
      selectedExpertiseIds: selectedExpertiseIds,
      expertiseOptions: expertiseOptions,
      currentPage: safePage,
      itemsPerPage: _itemsPerPage,
      totalPages: totalPages,
      hasNextPage: safePage < totalPages,
    );
  }

  List<UstadzModel> _filteredUstadz(
    List<UstadzModel> ustadzList,
    String searchQuery,
    int selectedStatusIndex,
    Set<int> selectedExpertiseIds,
  ) {
    return ustadzList.where((ustadz) {
      final hasRole = _hasAllowedRole(ustadz);
      if (!hasRole) return false;

      final matchStatus = _matchStatus(ustadz, selectedStatusIndex);
      if (!matchStatus) return false;

      final matchExpertise = _matchExpertise(ustadz, selectedExpertiseIds);
      if (!matchExpertise) return false;

      final query = searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;

      final name = (ustadz.name ?? '').toLowerCase();
      final title = (ustadz.title ?? '').toLowerCase();
      final expertises = ustadz.expertiseNames.join(' ').toLowerCase();

      return name.contains(query) ||
          title.contains(query) ||
          expertises.contains(query);
    }).toList();
  }

  bool _hasAllowedRole(UstadzModel ustadz) {
    if (allowedRoleSlugs.isEmpty) return true;

    return ustadz.roles.any((role) {
      final slug = (role.slug ?? '').toLowerCase().trim();
      return allowedRoleSlugs.contains(slug);
    });
  }

  bool _matchStatus(UstadzModel ustadz, int selectedStatusIndex) {
    final status = (ustadz.status ?? '').toLowerCase().trim();

    switch (selectedStatusIndex) {
      case 1:
        return status == 'aktif';
      case 2:
        return status == 'nonaktif';
      default:
        return true;
    }
  }

  bool _matchExpertise(UstadzModel ustadz, Set<int> selectedExpertiseIds) {
    if (selectedExpertiseIds.isEmpty) return true;

    return ustadz.expertises.any(
      (exp) => selectedExpertiseIds.contains(exp.id),
    );
  }

  List<FilterOption> _buildExpertiseOptions(List<UstadzModel> ustadzList) {
    final map = <int, String>{};

    for (final ustadz in ustadzList) {
      for (final exp in ustadz.expertises) {
        final id = exp.id;
        final name = exp.name;

        if (name != null && name.trim().isNotEmpty) {
          map[id] = name;
        }
      }
    }

    final options = map.entries
        .map((e) => FilterOption(id: e.key, name: e.value))
        .toList();

    options.sort((a, b) => a.name.compareTo(b.name));

    return options;
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
