import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puldapii/models/institution_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:puldapii/utils/services/institute/institution_service.dart';

import 'institution_state.dart';

class InstitutionCubit extends Cubit<InstitutionState> {
  InstitutionCubit(this._service) : super(const InstitutionState());

  final InstitutionService _service;

  Future<void> fetchInstitutions({
    String q = '',
    int page = 1,
    int perPage = 10,
  }) async {
    emit(
      state.copyWith(
        isListLoading: true,
        isLoadingMore: false,
        query: q,
        perPage: perPage,
        clearError: true,
      ),
    );

    try {
      final result = await _service.getInstitutions(
        q: q,
        page: page,
        perPage: perPage,
      );

      final pagination = Map<String, dynamic>.from(result['data']);
      final rawList = pagination['data'] as List? ?? [];

      final institutions = rawList
          .map((e) => InstitutionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      emit(
        state.copyWith(
          isListLoading: false,
          institutions: institutions,
          currentPage: _toInt(pagination['current_page']) ?? 1,
          lastPage: _toInt(pagination['last_page']) ?? 1,
          perPage: _toInt(pagination['per_page']) ?? perPage,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isListLoading: false, errorMessage: _errorMessage(e)),
      );
    }
  }

  Future<void> fetchInstitutionStats() async {
    if (state.isStatsLoading) return;

    emit(state.copyWith(isStatsLoading: true, clearError: true));

    try {
      final result = await _service.getInstitutionStats();

      final data = Map<String, dynamic>.from(result['data'] ?? {});

      emit(
        state.copyWith(
          isStatsLoading: false,
          totalInstitutions:
              _toInt(data['total_institutions'] ?? data['total']) ?? 0,
          totalProvinces:
              _toInt(data['total_provinces'] ?? data['provinces']) ?? 0,
          totalCities: _toInt(data['total_cities'] ?? data['cities']) ?? 0,
          totalVerified:
              _toInt(data['total_verified'] ?? data['verified']) ?? 0,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isStatsLoading: false, errorMessage: _errorMessage(e)),
      );
    }
  }

  Future<void> searchInstitutions(String keyword) async {
    await fetchInstitutions(q: keyword, page: 1, perPage: state.perPage);
  }

  Future<void> refreshInstitutions() async {
    await fetchInstitutions(q: state.query, page: 1, perPage: state.perPage);
  }

  Future<void> loadMoreInstitutions() async {
    if (state.isLoadingMore) return;
    if (state.isListLoading) return;
    if (state.hasReachedEnd) return;

    final nextPage = state.currentPage + 1;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final result = await _service.getInstitutions(
        q: state.query,
        page: nextPage,
        perPage: state.perPage,
      );

      final pagination = Map<String, dynamic>.from(result['data']);
      final rawList = pagination['data'] as List? ?? [];

      final newItems = rawList
          .map((e) => InstitutionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      emit(
        state.copyWith(
          isLoadingMore: false,
          institutions: [...state.institutions, ...newItems],
          currentPage: _toInt(pagination['current_page']) ?? nextPage,
          lastPage: _toInt(pagination['last_page']) ?? state.lastPage,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingMore: false, errorMessage: _errorMessage(e)),
      );
    }
  }

  Future<void> fetchInstitutionDetail(int id) async {
    emit(
      state.copyWith(
        isDetailLoading: true,
        clearDetail: true,
        clearError: true,
      ),
    );

    try {
      final result = await _service.getInstitutionDetail(id);

      final data = Map<String, dynamic>.from(result['data']);
      final detail = InstitutionModel.fromJson(data);

      emit(
        state.copyWith(
          isDetailLoading: false,
          detail: detail,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isDetailLoading: false, errorMessage: _errorMessage(e)),
      );
    }
  }

  void clearDetail() {
    emit(state.copyWith(clearDetail: true, clearError: true));
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String _errorMessage(Object error) {
  if (error is ApiFailure) {
    return error.message;
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
