import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:puldapii/utils/services/home/consultation_service.dart';
import 'package:puldapii/utils/services/home/expertise_service.dart';
import 'package:puldapii/utils/services/profile_service.dart';

part 'consultation_event.dart';
part 'consultation_state.dart';

class ConsultationBloc extends Bloc<ConsultationEvent, ConsultationState> {
  final ProfileService profileService;
  final ExpertiseService expertiseService;
  final ConsultationService consultationService;

  ConsultationBloc({
    required this.profileService,
    required this.expertiseService,
    required this.consultationService,
  }) : super(const ConsultationState()) {
    on<ConsultationStarted>(_onStarted);
    on<ConsultationExpertiseChanged>(_onExpertiseChanged);
    on<ConsultationSubmitted>(_onSubmitted);

    on<ConsultationIncomingStarted>(_onIncomingStarted);
    on<ConsultationIncomingRefreshed>(_onIncomingRefreshed);
    on<ConsultationAnswerSubmitted>(_onAnswerSubmitted);
    on<ConsultationHistoryStarted>(_onHistoryStarted);
    on<ConsultationHistoryRefreshed>(_onHistoryRefreshed);

    on<ConsultationIncomingPageChanged>(_onIncomingPageChanged);
    on<ConsultationHistoryPageChanged>(_onHistoryPageChanged);
  }

  Future<void> _onStarted(
    ConsultationStarted event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(
      state.copyWith(status: ConsultationStatus.loading, clearMessage: true),
    );

    try {
      final profileResponse = await profileService.getProfile();
      final expertises = await expertiseService.getExpertises();

      final data = profileResponse['data'] ?? profileResponse;
      final user = data['user'];
      final ustadz = data['ustadz'];

      final name =
          data['name']?.toString() ??
          ustadz?['name']?.toString() ??
          user?['name']?.toString() ??
          '';

      final phone =
          data['phone']?.toString() ??
          data['contact_number']?.toString() ??
          ustadz?['contact_number']?.toString() ??
          ustadz?['phone']?.toString() ??
          user?['phone']?.toString() ??
          user?['contact_number']?.toString() ??
          '';

      emit(
        state.copyWith(
          status: ConsultationStatus.loaded,
          name: name,
          phone: phone,
          expertises: expertises,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onExpertiseChanged(
    ConsultationExpertiseChanged event,
    Emitter<ConsultationState> emit,
  ) {
    emit(
      state.copyWith(
        selectedExpertiseId: event.expertiseId,
        clearMessage: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    ConsultationSubmitted event,
    Emitter<ConsultationState> emit,
  ) async {
    final expertiseId = state.selectedExpertiseId;

    if (expertiseId == null) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: 'Kategori tidak boleh kosong',
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: ConsultationStatus.submitting, clearMessage: true),
    );

    try {
      await consultationService.createConsultation(
        expertiseId: expertiseId,
        title: event.title,
        question: event.question,
      );

      emit(
        state.copyWith(
          status: ConsultationStatus.success,
          message: 'Konsultasi berhasil dikirim',
          clearSelectedExpertise: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  bool _isAnswered(Map<String, dynamic> item) {
    final statusRaw = item['status_raw']?.toString().toLowerCase().trim();
    final status = item['status']?.toString().toLowerCase().trim();

    return statusRaw == 'answered' ||
        status == 'answered' ||
        status == 'sudah dijawab';
  }

  List<Map<String, dynamic>> _sortUnansweredFirst(
    List<Map<String, dynamic>> items,
  ) {
    final sortedItems = [...items];

    sortedItems.sort((a, b) {
      final aAnswered = _isAnswered(a);
      final bAnswered = _isAnswered(b);

      if (aAnswered == bAnswered) return 0;

      // Belum dijawab di atas
      return aAnswered ? 1 : -1;
    });

    return sortedItems;
  }

  Future<void> _onIncomingStarted(
    ConsultationIncomingStarted event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ConsultationStatus.incomingLoading,
        clearMessage: true,
      ),
    );

    try {
      final result = await consultationService.getUstadzConsultations(
        page: event.page,
        perPage: event.perPage,
      );

      final sortedItems = _sortUnansweredFirst(result.items);

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          incomingConsultations: sortedItems,
          incomingTotalBelumDijawab: result.totalBelumDijawab,
          incomingTotalSudahDijawab: result.totalSudahDijawab,
          page: event.page,
          hasNextPage: event.page < result.lastPage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onIncomingRefreshed(
    ConsultationIncomingRefreshed event,
    Emitter<ConsultationState> emit,
  ) async {
    try {
      final result = await consultationService.getUstadzConsultations(
        page: event.page,
        perPage: event.perPage,
      );

      final sortedItems = _sortUnansweredFirst(result.items);

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          incomingConsultations: sortedItems,
          incomingTotalBelumDijawab: result.totalBelumDijawab,
          incomingTotalSudahDijawab: result.totalSudahDijawab,
          page: result.currentPage,
          hasNextPage: result.currentPage < result.lastPage,
          clearMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAnswerSubmitted(
    ConsultationAnswerSubmitted event,
    Emitter<ConsultationState> emit,
  ) async {
    final answer = event.answer.trim();

    if (answer.isEmpty) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: 'Jawaban tidak boleh kosong',
        ),
      );
      return;
    }

    if (answer.length < 10) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: 'Jawaban terlalu pendek',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ConsultationStatus.answering,
        answeringConsultationId: event.consultationId,
        clearMessage: true,
      ),
    );

    try {
      final response = await consultationService.answerConsultation(
        consultationId: event.consultationId,
        answer: answer,
      );

      Map<String, dynamic>? answeredConsultation;

      if (response['data'] is Map) {
        answeredConsultation = Map<String, dynamic>.from(response['data']);
      }

      final updatedConsultations = state.incomingConsultations.map((item) {
        if (item['id'] == event.consultationId) {
          return {
            ...item,
            'status': 'Sudah Dijawab',
            'status_raw': 'answered',
            'jawaban': answer,
            'ustadz_id':
                answeredConsultation?['ustadz_id'] ?? item['ustadz_id'],
            'answered_at':
                answeredConsultation?['answered_at'] ?? item['answered_at'],
          };
        }

        return item;
      }).toList();

      final sortedUpdatedConsultations = _sortUnansweredFirst(
        updatedConsultations,
      );

      final currentTotalBelum = state.incomingTotalBelumDijawab;
      final currentTotalSudah = state.incomingTotalSudahDijawab;

      emit(
        state.copyWith(
          status: ConsultationStatus.answerSuccess,
          incomingConsultations: sortedUpdatedConsultations,
          incomingTotalBelumDijawab: currentTotalBelum > 0
              ? currentTotalBelum - 1
              : 0,
          incomingTotalSudahDijawab: currentTotalSudah + 1,
          message: 'Jawaban berhasil dikirim',
          clearAnsweringConsultationId: true,
        ),
      );

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          clearMessage: true,
          clearAnsweringConsultationId: true,
        ),
      );
      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          clearMessage: true,
          clearAnsweringConsultationId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
          clearAnsweringConsultationId: true,
        ),
      );
    }
  }

  Future<void> _onIncomingPageChanged(
    ConsultationIncomingPageChanged event,
    Emitter<ConsultationState> emit,
  ) async {
    final previousItems = state.incomingConsultations;
    final previousPage = state.page;
    final previousTotalBelum = state.incomingTotalBelumDijawab;
    final previousTotalSudah = state.incomingTotalSudahDijawab;

    emit(
      state.copyWith(
        status: ConsultationStatus.incomingLoading,
        clearMessage: true,
      ),
    );

    try {
      final result = await consultationService.getUstadzConsultations(
        page: event.page,
        perPage: event.perPage,
      );

      if (result.items.isEmpty && event.page > 1) {
        emit(
          state.copyWith(
            status: ConsultationStatus.incomingLoaded,
            incomingConsultations: previousItems,
            incomingTotalBelumDijawab: previousTotalBelum,
            incomingTotalSudahDijawab: previousTotalSudah,
            page: previousPage,
            hasNextPage: false,
          ),
        );
        return;
      }

      final sortedItems = _sortUnansweredFirst(result.items);

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          incomingConsultations: sortedItems,
          incomingTotalBelumDijawab: result.totalBelumDijawab,
          incomingTotalSudahDijawab: result.totalSudahDijawab,
          page: event.page,
          hasNextPage: event.page < result.lastPage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          incomingConsultations: previousItems,
          incomingTotalBelumDijawab: previousTotalBelum,
          incomingTotalSudahDijawab: previousTotalSudah,
          page: previousPage,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onHistoryStarted(
    ConsultationHistoryStarted event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ConsultationStatus.incomingLoading,
        page: event.page,
        clearMessage: true,
      ),
    );

    try {
      final consultations = await consultationService.getMyConsultations(
        page: event.page,
        perPage: event.perPage,
      );

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          myConsultations: consultations,
          page: event.page,
          hasNextPage: consultations.length >= event.perPage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onHistoryRefreshed(
    ConsultationHistoryRefreshed event,
    Emitter<ConsultationState> emit,
  ) async {
    try {
      final consultations = await consultationService.getMyConsultations(
        page: event.page,
        perPage: event.perPage,
      );

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          myConsultations: consultations,
          page: event.page,
          hasNextPage: consultations.length >= event.perPage,
          clearMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onHistoryPageChanged(
    ConsultationHistoryPageChanged event,
    Emitter<ConsultationState> emit,
  ) async {
    final previousItems = state.myConsultations;
    final previousPage = state.page;

    emit(
      state.copyWith(
        status: ConsultationStatus.incomingLoading,
        clearMessage: true,
      ),
    );

    try {
      final consultations = await consultationService.getMyConsultations(
        page: event.page,
        perPage: event.perPage,
      );

      if (consultations.isEmpty && event.page > 1) {
        emit(
          state.copyWith(
            status: ConsultationStatus.incomingLoaded,
            myConsultations: previousItems,
            page: previousPage,
            hasNextPage: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ConsultationStatus.incomingLoaded,
          myConsultations: consultations,
          page: event.page,
          hasNextPage: consultations.length >= event.perPage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultationStatus.failure,
          myConsultations: previousItems,
          page: previousPage,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
