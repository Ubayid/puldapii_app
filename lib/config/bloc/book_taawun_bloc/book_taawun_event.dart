part of 'book_taawun_bloc.dart';

sealed class BookTaawunEvent extends Equatable {
  const BookTaawunEvent();

  @override
  List<Object?> get props => [];
}

final class BookTaawunInitialized extends BookTaawunEvent {
  final String status;
  final String search;
  final int page;
  final int perPage;
  final bool loadBooks;

  const BookTaawunInitialized({
    this.status = '',
    this.search = '',
    this.page = 1,
    this.perPage = 10,
    this.loadBooks = true,
  });

  @override
  List<Object?> get props => [status, search, page, perPage, loadBooks];
}

final class BookTaawunLoaded extends BookTaawunEvent {
  final String status;
  final String search;
  final int page;
  final int perPage;

  const BookTaawunLoaded({
    this.status = '',
    this.search = '',
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [status, search, page, perPage];
}

final class BookTaawunRefreshed extends BookTaawunEvent {
  const BookTaawunRefreshed();
}

final class BookTaawunPageChanged extends BookTaawunEvent {
  final int page;

  const BookTaawunPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

final class BookTaawunSearchChanged extends BookTaawunEvent {
  final String search;

  const BookTaawunSearchChanged(this.search);

  @override
  List<Object?> get props => [search];
}

final class BookTaawunStatusChanged extends BookTaawunEvent {
  final String status;

  const BookTaawunStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

final class BookTaawunActiveBooksLoaded extends BookTaawunEvent {
  const BookTaawunActiveBooksLoaded();
}

final class BookTaawunDetailLoaded extends BookTaawunEvent {
  final int id;

  const BookTaawunDetailLoaded(this.id);

  @override
  List<Object?> get props => [id];
}

final class BookTaawunCreated extends BookTaawunEvent {
  final int bookId;
  final String donorName;
  final String donorWhatsapp;
  final String? donorEmail;
  final int amount;

  const BookTaawunCreated({
    required this.bookId,
    required this.donorName,
    required this.donorWhatsapp,
    this.donorEmail,
    required this.amount,
  });

  @override
  List<Object?> get props => [
    bookId,
    donorName,
    donorWhatsapp,
    donorEmail,
    amount,
  ];
}

final class BookTaawunUpdated extends BookTaawunEvent {
  final int id;
  final int bookId;
  final String donorName;
  final String donorWhatsapp;
  final String? donorEmail;
  final int amount;
  final XFile? paymentProof;
  final bool removePaymentProof;

  const BookTaawunUpdated({
    required this.id,
    required this.bookId,
    required this.donorName,
    required this.donorWhatsapp,
    this.donorEmail,
    required this.amount,
    this.paymentProof,
    this.removePaymentProof = false,
  });

  @override
  List<Object?> get props => [
    id,
    bookId,
    donorName,
    donorWhatsapp,
    donorEmail,
    amount,
    paymentProof,
    removePaymentProof,
  ];
}

final class BookTaawunApproved extends BookTaawunEvent {
  final int id;

  const BookTaawunApproved(this.id);

  @override
  List<Object?> get props => [id];
}

final class BookTaawunCancelled extends BookTaawunEvent {
  final int id;

  const BookTaawunCancelled(this.id);

  @override
  List<Object?> get props => [id];
}

final class BookTaawunDeleted extends BookTaawunEvent {
  final int id;

  const BookTaawunDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

final class BookTaawunRejected extends BookTaawunEvent {
  const BookTaawunRejected();
}

final class BookTaawunMessageCleared extends BookTaawunEvent {
  const BookTaawunMessageCleared();
}
