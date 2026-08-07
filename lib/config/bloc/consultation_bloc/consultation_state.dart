part of 'consultation_bloc.dart';

enum ConsultationStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,

  incomingLoading,
  incomingLoaded,
  answering,
  answerSuccess,
  incomingTotalBelumDijawab,
  incomingTotalSudahDijawab,
}

class ConsultationState extends Equatable {
  final ConsultationStatus status;
  final String name;
  final String phone;
  final List<Map<String, dynamic>> expertises;
  final int? selectedExpertiseId;
  final String? message;

  final List<Map<String, dynamic>> incomingConsultations;
  final int? answeringConsultationId;
  final List<Map<String, dynamic>> myConsultations;

  final int page;
  final bool hasNextPage;

  final int incomingTotalBelumDijawab;
  final int incomingTotalSudahDijawab;

  const ConsultationState({
    this.status = ConsultationStatus.initial,
    this.name = '',
    this.phone = '',
    this.expertises = const [],
    this.selectedExpertiseId,
    this.message,
    this.incomingConsultations = const [],
    this.answeringConsultationId,
    this.myConsultations = const [],
    this.page = 1,
    this.hasNextPage = false,
    this.incomingTotalBelumDijawab = 0,
    this.incomingTotalSudahDijawab = 0,
  });

  int get belumDijawabCount {
    return incomingConsultations
        .where((item) => item['status']?.toString() != 'Sudah Dijawab')
        .length;
  }

  int get sudahDijawabCount {
    return incomingConsultations
        .where((item) => item['status']?.toString() == 'Sudah Dijawab')
        .length;
  }

  ConsultationState copyWith({
    ConsultationStatus? status,
    String? name,
    String? phone,
    List<Map<String, dynamic>>? expertises,
    int? selectedExpertiseId,
    String? message,
    bool clearMessage = false,
    bool clearSelectedExpertise = false,
    List<Map<String, dynamic>>? incomingConsultations,
    int? answeringConsultationId,
    List<Map<String, dynamic>>? myConsultations,
    bool clearAnsweringConsultationId = false,
    int? page,
    bool? hasNextPage,
    int? incomingTotalBelumDijawab,
    int? incomingTotalSudahDijawab,
  }) {
    return ConsultationState(
      status: status ?? this.status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      expertises: expertises ?? this.expertises,
      selectedExpertiseId: clearSelectedExpertise
          ? null
          : selectedExpertiseId ?? this.selectedExpertiseId,
      message: clearMessage ? null : message ?? this.message,
      incomingConsultations:
          incomingConsultations ?? this.incomingConsultations,
      answeringConsultationId: clearAnsweringConsultationId
          ? null
          : answeringConsultationId ?? this.answeringConsultationId,
      myConsultations: myConsultations ?? this.myConsultations,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      incomingTotalBelumDijawab:
          incomingTotalBelumDijawab ?? this.incomingTotalBelumDijawab,
      incomingTotalSudahDijawab:
          incomingTotalSudahDijawab ?? this.incomingTotalSudahDijawab,
    );
  }

  @override
  List<Object?> get props => [
    status,
    name,
    phone,
    expertises,
    selectedExpertiseId,
    message,
    incomingConsultations,
    answeringConsultationId,
    page,
    hasNextPage,
    incomingTotalBelumDijawab,
    incomingTotalSudahDijawab,
  ];
}
