abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignupRequested(this.email, this.password);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

// For password reset
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  AuthPasswordResetRequested(this.email);
}
