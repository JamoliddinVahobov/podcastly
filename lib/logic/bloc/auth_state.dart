import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {
  final String message; // Custom message to provide context

  AuthLoading({this.message = "Please wait..."});
}

class AuthError extends AuthState {
  final String? emailError;
  final String? passwordError;
  final String? message; // Add this line

  AuthError({this.emailError, this.passwordError, this.message});
}
