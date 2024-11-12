import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  AuthSignupRequested(this.email, this.password, this.username);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthResendVerificationEmail extends AuthEvent {
  final User user;

  AuthResendVerificationEmail({required this.user});
}

// For password reset
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  AuthPasswordResetRequested(this.email);
}
