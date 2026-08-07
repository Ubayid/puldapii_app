part of 'book_recipient_bloc.dart';

abstract class BookRecipientEvent {}

class SubmitBookRecipient extends BookRecipientEvent {
  final String token;
  final int bookId;
  final String institutionName;
  final String responsibleName;
  final String whatsappNumber;
  final String address;
  final String city;
  final String province;
  final String institutionType;
  final int requestedQuantity;
  final int? peopleCount;
  final String? reason;
  final File? institutionPhoto;
  final bool isConfirmed;

  SubmitBookRecipient({
    required this.token,
    required this.bookId,
    required this.institutionName,
    required this.responsibleName,
    required this.whatsappNumber,
    required this.address,
    required this.city,
    required this.province,
    required this.institutionType,
    required this.requestedQuantity,
    this.peopleCount,
    this.reason,
    this.institutionPhoto,
    required this.isConfirmed,
  });
}

class FetchBookRecipientDetail extends BookRecipientEvent {
  final String token;
  final int id;

  FetchBookRecipientDetail({required this.token, required this.id});
}

class FetchMyBookRecipients extends BookRecipientEvent {
  final String token;

  FetchMyBookRecipients({required this.token});
}
