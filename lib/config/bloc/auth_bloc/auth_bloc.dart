import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:puldapii/utils/services/auth_service.dart';
import 'package:puldapii/utils/services/firebase_notification_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim();
    final password = event.password;

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Email dan password wajib diisi'));
      return;
    }

    emit(AuthLoading());

    try {
      final response = await authService.login(
        email: email,
        password: password,
      );

      try {
        await FirebaseNotificationService.saveTokenToBackend();
        // await authService.testSaveFcmToken();
      } catch (e) {
        print('GAGAL SIMPAN FCM TOKEN SETELAH LOGIN: $e');
      }

      emit(AuthSuccess(response['message'] ?? 'Login berhasil'));
    } on DioException catch (e) {
      print('STATUS CODE: ${e.response?.statusCode}');
      print('ERROR DATA: ${e.response?.data}');
      print('ERROR MESSAGE: ${e.message}');
      emit(AuthFailure(_getErrorMessage(e, 'Login gagal')));
    } catch (_) {
      emit(const AuthFailure('Terjadi kesalahan. Coba lagi nanti.'));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final name = event.name.trim();
    final email = event.email.trim();
    final password = event.password;
    final passwordConfirmation = event.passwordConfirmation;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      emit(const AuthFailure('Semua data wajib diisi'));
      return;
    }

    if (password.length < 8) {
      emit(const AuthFailure('Password minimal 8 karakter'));
      return;
    }

    if (password != passwordConfirmation) {
      emit(const AuthFailure('Konfirmasi password tidak sama'));
      return;
    }

    emit(AuthLoading());

    try {
      final response = await authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      try {
        await FirebaseNotificationService.saveTokenToBackend();
      } catch (e) {
        print('GAGAL SIMPAN FCM TOKEN SETELAH REGISTER: $e');
      }

      emit(AuthSuccess(response['message'] ?? 'Daftar akun berhasil'));
    } on DioException catch (e) {
      emit(AuthFailure(_getErrorMessage(e, 'Daftar akun gagal')));
    } catch (_) {
      emit(const AuthFailure('Terjadi kesalahan. Coba lagi nanti.'));
    }
  }

  String _getErrorMessage(DioException e, String defaultMessage) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return defaultMessage;
  }
}
