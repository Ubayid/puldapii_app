part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountStarted extends AccountEvent {}

class AccountRefreshed extends AccountEvent {}

class AccountLoggedOut extends AccountEvent {}

class AccountProfileUpdated extends AccountEvent {
  final Map<String, dynamic> user;

  const AccountProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
