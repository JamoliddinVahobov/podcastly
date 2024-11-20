// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);

  List<Object> get props => [user];
}

class AuthEmailVerificationRequired extends AuthState {
  final User user;

  AuthEmailVerificationRequired(this.user);

  List<Object> get props => [user];
}

class EmailResent extends AuthState {
  final String message;
  EmailResent({
    required this.message,
  });
}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {
  final String message;

  AuthLoading({this.message = "Please wait..."});
}

class AuthError extends AuthState {
  final String? emailError;
  final String? passwordError;
  final String? usernameError;
  final String message;
  final String source;

  AuthError({
    this.usernameError,
    this.emailError,
    this.passwordError,
    required this.message,
    this.source = '',
  });
}
