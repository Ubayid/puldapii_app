part of 'book_recipient_bloc.dart';

abstract class BookRecipientState {}

class BookRecipientInitial extends BookRecipientState {}

class BookRecipientLoading extends BookRecipientState {}

class BookRecipientSuccess extends BookRecipientState {
  final String message;
  final Map<String, dynamic>? data;

  BookRecipientSuccess({required this.message, this.data});
}

class BookRecipientDetailLoaded extends BookRecipientState {
  final Map<String, dynamic> data;

  BookRecipientDetailLoaded({required this.data});
}

class BookRecipientError extends BookRecipientState {
  final String message;

  BookRecipientError(this.message);
}

class BookRecipientListLoaded extends BookRecipientState {
  final List<BookRecipientModel> data;

  BookRecipientListLoaded({required this.data});
}
