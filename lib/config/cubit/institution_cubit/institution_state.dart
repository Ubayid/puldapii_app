import 'package:puldapii/models/institution_model.dart';

class InstitutionState {
  final bool isListLoading;
  final bool isDetailLoading;
  final bool isLoadingMore;
  final bool isStatsLoading;

  final List<InstitutionModel> institutions;
  final InstitutionModel? detail;

  final String query;

  final int currentPage;
  final int lastPage;
  final int perPage;

  // Statistik keseluruhan
  final int totalInstitutions;
  final int totalProvinces;
  final int totalCities;
  final int totalVerified;

  final String? errorMessage;

  const InstitutionState({
    this.isListLoading = false,
    this.isDetailLoading = false,
    this.isLoadingMore = false,
    this.isStatsLoading = false,
    this.institutions = const [],
    this.detail,
    this.query = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.totalInstitutions = 0,
    this.totalProvinces = 0,
    this.totalCities = 0,
    this.totalVerified = 0,
    this.errorMessage,
  });

  bool get hasReachedEnd => currentPage >= lastPage;

  InstitutionState copyWith({
    bool? isListLoading,
    bool? isDetailLoading,
    bool? isLoadingMore,
    bool? isStatsLoading,
    List<InstitutionModel>? institutions,
    InstitutionModel? detail,
    bool clearDetail = false,
    String? query,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? totalInstitutions,
    int? totalProvinces,
    int? totalCities,
    int? totalVerified,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InstitutionState(
      isListLoading: isListLoading ?? this.isListLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      institutions: institutions ?? this.institutions,
      detail: clearDetail ? null : detail ?? this.detail,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      totalInstitutions: totalInstitutions ?? this.totalInstitutions,
      totalProvinces: totalProvinces ?? this.totalProvinces,
      totalCities: totalCities ?? this.totalCities,
      totalVerified: totalVerified ?? this.totalVerified,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
