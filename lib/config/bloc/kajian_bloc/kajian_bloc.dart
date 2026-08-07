import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:puldapii/models/dakwah_model.dart';
import 'package:puldapii/models/dakwah_tags_option_model.dart';
import 'package:puldapii/utils/services/home/dakwah_service.dart';

part 'kajian_event.dart';
part 'kajian_state.dart';

class KajianBloc extends Bloc<KajianEvent, KajianState> {
  final DakwahService service;

  KajianBloc(this.service) : super(const KajianState()) {
    on<FetchKajianData>(_onFetchKajianData);
    on<RefreshKajianData>(_onRefreshKajianData);
    on<ChangeKajianPage>(_onChangeKajianPage);
    on<UpdateKajianSearch>(_onUpdateKajianSearch);
    on<UpdateKajianMainFilter>(_onUpdateKajianMainFilter);
    on<UpdateKajianTags>(_onUpdateKajianTags);
    on<RemoveKajianTag>(_onRemoveKajianTag);
  }

  Future<void> _onFetchKajianData(
    FetchKajianData event,
    Emitter<KajianState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        page: event.page,
        perPage: event.perPage,
        clearError: true,
      ),
    );

    try {
      final paginated = await service.fetchDakwah(
        page: event.page,
        perPage: event.perPage,
        tagIds: state.selectedTagIds.isEmpty ? null : state.selectedTagIds,
      );

      final tagOptions = await service.fetchTagOptions();

      final position = await _getUserLocationSafe();

      final nextState = state.copyWith(
        isLoading: false,
        rawItems: paginated.items,
        tagOptions: tagOptions,
        userPosition: position,
        page: paginated.currentPage,
        perPage: paginated.perPage,
        hasNextPage: paginated.nextPageUrl != null,
        lastPage: paginated.lastPage,
        total: paginated.total,
        clearError: true,
      );

      emit(
        nextState.copyWith(
          filteredItems: _applyAllFilters(
            items: nextState.rawItems,
            selectedFilter: nextState.selectedFilter,
            selectedTagIds: nextState.selectedTagIds,
            searchQuery: nextState.searchQuery,
            userPosition: nextState.userPosition,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat kajian: ${_cleanError(e)}',
        ),
      );
    }
  }

  Future<void> _onRefreshKajianData(
    RefreshKajianData event,
    Emitter<KajianState> emit,
  ) async {
    add(FetchKajianData(page: state.page, perPage: state.perPage));
  }

  Future<void> _onChangeKajianPage(
    ChangeKajianPage event,
    Emitter<KajianState> emit,
  ) async {
    add(FetchKajianData(page: event.page, perPage: state.perPage));
  }

  void _onUpdateKajianSearch(
    UpdateKajianSearch event,
    Emitter<KajianState> emit,
  ) {
    final nextState = state.copyWith(
      searchQuery: event.query,
      clearError: true,
    );

    emit(
      nextState.copyWith(
        filteredItems: _applyAllFilters(
          items: nextState.rawItems,
          selectedFilter: nextState.selectedFilter,
          selectedTagIds: nextState.selectedTagIds,
          searchQuery: nextState.searchQuery,
          userPosition: nextState.userPosition,
        ),
      ),
    );
  }

  void _onUpdateKajianMainFilter(
    UpdateKajianMainFilter event,
    Emitter<KajianState> emit,
  ) {
    final nextState = state.copyWith(
      selectedFilter: event.selectedFilter,
      clearError: true,
    );

    emit(
      nextState.copyWith(
        filteredItems: _applyAllFilters(
          items: nextState.rawItems,
          selectedFilter: nextState.selectedFilter,
          selectedTagIds: nextState.selectedTagIds,
          searchQuery: nextState.searchQuery,
          userPosition: nextState.userPosition,
        ),
      ),
    );
  }

  Future<void> _onUpdateKajianTags(
    UpdateKajianTags event,
    Emitter<KajianState> emit,
  ) async {
    final selectedTagIds = Set<int>.from(event.selectedTagIds);
    final currentPerPage = state.perPage;

    emit(
      state.copyWith(
        isLoading: true,
        selectedTagIds: selectedTagIds,
        page: 1,
        clearError: true,
      ),
    );

    try {
      final paginated = await service.fetchDakwah(
        page: 1,
        perPage: currentPerPage,
        tagIds: selectedTagIds.isEmpty ? null : selectedTagIds,
      );

      final nextState = state.copyWith(
        isLoading: false,
        rawItems: paginated.items,
        selectedTagIds: selectedTagIds,
        page: paginated.currentPage,
        perPage: paginated.perPage,
        hasNextPage: paginated.nextPageUrl != null,
        lastPage: paginated.lastPage,
        total: paginated.total,
        clearError: true,
      );

      emit(
        nextState.copyWith(
          filteredItems: _applyAllFilters(
            items: nextState.rawItems,
            selectedFilter: nextState.selectedFilter,
            selectedTagIds: nextState.selectedTagIds,
            searchQuery: nextState.searchQuery,
            userPosition: nextState.userPosition,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat kajian: ${_cleanError(e)}',
        ),
      );
    }
  }

  Future<void> _onRemoveKajianTag(
    RemoveKajianTag event,
    Emitter<KajianState> emit,
  ) async {
    final updatedTags = Set<int>.from(state.selectedTagIds)
      ..remove(event.tagId);

    add(UpdateKajianTags(updatedTags));
  }

  Future<Position?> _getUserLocationSafe() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  List<DakwahModel> _applyAllFilters({
    required List<DakwahModel> items,
    required int selectedFilter,
    required Set<int> selectedTagIds,
    required String searchQuery,
    required Position? userPosition,
  }) {
    var result = List<DakwahModel>.from(items);

    result = _applyMainFilter(result, selectedFilter, userPosition);

    result = _applyTagFilter(result, selectedTagIds);

    result = _applySearchFilter(result, searchQuery);

    return result;
  }

  List<DakwahModel> _applyTagFilter(
    List<DakwahModel> items,
    Set<int> selectedTagIds,
  ) {
    if (selectedTagIds.isEmpty) {
      return items;
    }

    return items.where((dakwah) {
      return dakwah.tags.any((tag) => selectedTagIds.contains(tag.id));
    }).toList();
  }

  List<DakwahModel> _applyMainFilter(
    List<DakwahModel> items,
    int selectedFilter,
    Position? userPosition,
  ) {
    switch (selectedFilter) {
      case 0:
        final sorted = [...items];

        sorted.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          return bTime.compareTo(aTime);
        });

        return sorted;

      case 1:
        if (userPosition == null) {
          return items;
        }

        final sorted = [...items];

        sorted.sort((a, b) {
          final aHasCoord = a.locationLat != null && a.locationLng != null;
          final bHasCoord = b.locationLat != null && b.locationLng != null;

          if (!aHasCoord && !bHasCoord) return 0;
          if (!aHasCoord) return 1;
          if (!bHasCoord) return -1;

          final distanceA = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            a.locationLat!,
            a.locationLng!,
          );

          final distanceB = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            b.locationLat!,
            b.locationLng!,
          );

          return distanceA.compareTo(distanceB);
        });

        return sorted;

      case 2:
        final sorted = [...items];

        sorted.sort((a, b) {
          return a.date.compareTo(b.date);
        });

        return sorted;

      default:
        return items;
    }
  }

  List<DakwahModel> _applySearchFilter(
    List<DakwahModel> items,
    String searchQuery,
  ) {
    if (searchQuery.trim().isEmpty) {
      return items;
    }

    final q = searchQuery.toLowerCase();

    return items.where((dakwah) {
      final title = dakwah.title.toLowerCase();
      final ustadz = (dakwah.ustadz ?? '').toString().toLowerCase();
      final location = dakwah.location.toLowerCase();
      final address = (dakwah.locationAddress ?? '').toLowerCase();

      return title.contains(q) ||
          ustadz.contains(q) ||
          location.contains(q) ||
          address.contains(q);
    }).toList();
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
