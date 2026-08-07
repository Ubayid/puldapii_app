import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puldapii/models/book_recipient_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:puldapii/utils/services/home/book_recipient_service.dart';

part 'book_recipient_event.dart';
part 'book_recipient_state.dart';

class BookRecipientBloc extends Bloc<BookRecipientEvent, BookRecipientState> {
  BookRecipientBloc() : super(BookRecipientInitial()) {
    on<SubmitBookRecipient>(_onSubmit);
    on<FetchBookRecipientDetail>(_onFetchDetail);
    on<FetchMyBookRecipients>(_onFetchMyApplications);
  }

  Future<void> _onSubmit(
    SubmitBookRecipient event,
    Emitter<BookRecipientState> emit,
  ) async {
    emit(BookRecipientLoading());

    try {
      final result = await BookRecipientService.store(
        token: event.token,
        bookId: event.bookId,
        institutionName: event.institutionName,
        responsibleName: event.responsibleName,
        whatsappNumber: event.whatsappNumber,
        address: event.address,
        city: event.city,
        province: event.province,
        institutionType: event.institutionType,
        requestedQuantity: event.requestedQuantity,
        peopleCount: event.peopleCount,
        reason: event.reason,
        institutionPhoto: event.institutionPhoto,
        isConfirmed: event.isConfirmed,
      );

      emit(
        BookRecipientSuccess(
          message:
              result['message']?.toString() ??
              'Pengajuan penerima buku berhasil dikirim.',
          data: result['data'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(result['data'])
              : null,
        ),
      );
    } catch (e) {
      emit(BookRecipientError(_errorMessage(e)));
    }
  }

  Future<void> _onFetchDetail(
    FetchBookRecipientDetail event,
    Emitter<BookRecipientState> emit,
  ) async {
    emit(BookRecipientLoading());

    try {
      final result = await BookRecipientService.show(
        token: event.token,
        id: event.id,
      );

      emit(
        BookRecipientDetailLoaded(
          data: result['data'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(result['data'])
              : {},
        ),
      );
    } catch (e) {
      emit(BookRecipientError(_errorMessage(e)));
    }
  }

  Future<void> _onFetchMyApplications(
    FetchMyBookRecipients event,
    Emitter<BookRecipientState> emit,
  ) async {
    emit(BookRecipientLoading());

    try {
      final result = await BookRecipientService.myApplications(
        token: event.token,
      );

      emit(BookRecipientListLoaded(data: result));
    } catch (e) {
      emit(BookRecipientError(_errorMessage(e)));
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiFailure) {
      return error.message;
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
