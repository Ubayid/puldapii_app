import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:puldapii/utils/services/auth_service.dart';
import 'package:puldapii/utils/services/profile_service.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AuthService authService;
  final ProfileService profileService;

  AccountBloc({required this.authService, required this.profileService})
    : super(AccountInitial()) {
    on<AccountStarted>(_onStarted);
    on<AccountRefreshed>(_onRefreshed);
    on<AccountLoggedOut>(_onLoggedOut);
    on<AccountProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onStarted(
    AccountStarted event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());

    try {
      final response = await profileService.getProfile();

      final user = response['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(response['data'])
          : Map<String, dynamic>.from(response);

      emit(AccountLoaded(user));
    } catch (e) {
      debugPrint('ACCOUNT LOAD ERROR: $e');
      emit(const AccountFailure('Gagal memuat akun'));
    }
  }

  Future<void> _onRefreshed(
    AccountRefreshed event,
    Emitter<AccountState> emit,
  ) async {
    add(AccountStarted());
  }

  Future<void> _onLoggedOut(
    AccountLoggedOut event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await authService.logout();
    } catch (_) {
      await authService.removeToken();
    }

    emit(AccountLogoutSuccess());
  }

  void _onProfileUpdated(
    AccountProfileUpdated event,
    Emitter<AccountState> emit,
  ) {
    debugPrint('ACCOUNT UPDATED DIRECTLY: ${event.user}');
    emit(AccountLoaded(event.user));
  }
}
