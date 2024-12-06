// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthenticatedUser extends AuthState {
  final User user;

  AuthenticatedUser(this.user);

  List<Object> get props => [user];
}

class EmailVerificationRequired extends AuthState {
  final User user;

  EmailVerificationRequired(this.user);

  List<Object> get props => [user];
}

class EmailResent extends AuthState {
  final String message;
  EmailResent({
    required this.message,
  });
}

class UnauthenticatedUser extends AuthState {}

class AuthLoading extends AuthState {}

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
