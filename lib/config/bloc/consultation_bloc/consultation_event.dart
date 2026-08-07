part of 'consultation_bloc.dart';

sealed class ConsultationEvent extends Equatable {
  const ConsultationEvent();

  @override
  List<Object?> get props => [];
}

class ConsultationStarted extends ConsultationEvent {
  const ConsultationStarted();
}

class ConsultationExpertiseChanged extends ConsultationEvent {
  final int? expertiseId;

  const ConsultationExpertiseChanged(this.expertiseId);

  @override
  List<Object?> get props => [expertiseId];
}

class ConsultationSubmitted extends ConsultationEvent {
  final String title;
  final String question;

  const ConsultationSubmitted({required this.title, required this.question});

  @override
  List<Object?> get props => [title, question];
}

class ConsultationAnswerSubmitted extends ConsultationEvent {
  final int consultationId;
  final String answer;

  const ConsultationAnswerSubmitted({
    required this.consultationId,
    required this.answer,
  });

  @override
  List<Object?> get props => [consultationId, answer];
}

class ConsultationHistoryStarted extends ConsultationEvent {
  final int page;
  final int perPage;

  const ConsultationHistoryStarted({this.page = 1, this.perPage = 7});

  @override
  List<Object?> get props => [page, perPage];
}

class ConsultationHistoryPageChanged extends ConsultationEvent {
  final int page;
  final int perPage;

  const ConsultationHistoryPageChanged(this.page, {this.perPage = 7});

  @override
  List<Object?> get props => [page, perPage];
}

class ConsultationHistoryRefreshed extends ConsultationEvent {
  final int page;
  final int perPage;

  const ConsultationHistoryRefreshed({this.page = 1, this.perPage = 7});

  @override
  List<Object?> get props => [page, perPage];
}

class ConsultationIncomingStarted extends ConsultationEvent {
  final int page;
  final int perPage;

  const ConsultationIncomingStarted({this.page = 1, this.perPage = 7});

  @override
  List<Object?> get props => [page, perPage];
}

class ConsultationIncomingRefreshed extends ConsultationEvent {
  final int page;
  final int perPage;

  const ConsultationIncomingRefreshed({this.page = 1, this.perPage = 7});

  @override
  List<Object?> get props => [page, perPage];
}

class ConsultationIncomingPageChanged extends ConsultationEvent {
  final int page;
  final int perPage;

  const ConsultationIncomingPageChanged(this.page, {this.perPage = 7});

  @override
  List<Object?> get props => [page, perPage];
}
