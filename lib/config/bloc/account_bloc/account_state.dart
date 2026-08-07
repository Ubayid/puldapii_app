part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final Map<String, dynamic> user;

  const AccountLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class AccountFailure extends AccountState {
  final String message;

  const AccountFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountLogoutSuccess extends AccountState {}
