class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(
      [this.message = 'An unexpected error occurred', this.code]);

  @override
  String toString() => message;
}

class SignupException extends AuthException {
  final String? emailError;
  final String? passwordError;
  final String? usernameError;

  const SignupException({
    String message = 'Signup failed',
    String? code,
    this.emailError,
    this.passwordError,
    this.usernameError,
  }) : super(message, code);
}

class LoginException extends AuthException {
  final String? emailError;
  final String? passwordError;

  const LoginException({
    String message = 'Login failed',
    String? code,
    this.emailError,
    this.passwordError,
  }) : super(message, code);
}
