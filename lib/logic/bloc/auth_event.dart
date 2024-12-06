import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  SignupRequested(this.email, this.password, this.username);
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class ResendVerificationEmail extends AuthEvent {
  final User user;

  ResendVerificationEmail({required this.user});
}

// For password reset
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  AuthPasswordResetRequested(this.email);
}
