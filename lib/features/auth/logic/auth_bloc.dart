import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_exceptions/auth_exceptions.dart';

import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authService.signup(
          event.email,
          event.password,
          event.username,
        );
        emit(EmailVerificationRequired(user));
      } on SignupException catch (e) {
        emit(AuthError(
          emailError: e.emailError,
          passwordError: e.passwordError,
          usernameError: e.usernameError,
          message: e.message,
          source: 'signup_error',
        ));
      } on AuthException catch (e) {
        emit(AuthError(message: e.message, source: 'signup_error'));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        if (event.email.isEmpty || event.password.isEmpty) {
          throw const AuthException('Email and password cannot be empty');
        }
        final user = await _authService.login(event.email, event.password);
        emit(AuthenticatedUser(user));
      } on LoginException catch (e) {
        emit(AuthError(
          emailError: e.emailError,
          passwordError: e.passwordError,
          message: e.message,
          source: 'login_error',
        ));
      } on AuthException catch (e) {
        emit(AuthError(message: e.message, source: 'login_error'));
      }
    });

    on<ResendVerificationEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authService.resendVerificationEmail(event.user);
        emit(EmailResent(message: "Verification email has been resent."));
      } on AuthException catch (e) {
        emit(AuthError(
          message: e.message,
          source: 'resend_verification_error',
        ));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await _authService.logout();
        emit(UnauthenticatedUser());
      } on AuthException catch (e) {
        emit(AuthError(message: e.message, source: 'logout_error'));
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authService.checkAuthStatus();
        emit(user != null ? AuthenticatedUser(user) : UnauthenticatedUser());
      } on AuthException catch (e) {
        emit(AuthError(message: e.message, source: 'auth_check_error'));
      }
    });
  }
}
