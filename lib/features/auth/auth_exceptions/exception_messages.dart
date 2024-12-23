// auth_error_messages.dart

import 'exception_enums.dart';

class AuthErrorMessages {
  static String getMessage(AuthErrorCode code) {
    switch (code) {
      case AuthErrorCode.weakPassword:
        return 'The password provided is too weak';
      case AuthErrorCode.emailInUse:
        return 'An account already exists with this email';
      case AuthErrorCode.invalidEmail:
        return 'This email address is not valid';
      case AuthErrorCode.tooManyRequests:
        return 'Too many requests. Please try again later';
      case AuthErrorCode.invalidUsername:
        return 'The username is invalid';
      case AuthErrorCode.userNotFound:
        return 'No user found with this email';
      case AuthErrorCode.wrongPassword:
        return 'Incorrect password';
      case AuthErrorCode.networkError:
        return 'Network error, please check your connection';
      case AuthErrorCode.unknown:
        return 'Something went wrong, please try again';
    }
  }

  static String? getEmailError(AuthErrorCode code) {
    switch (code) {
      case AuthErrorCode.emailInUse:
      case AuthErrorCode.invalidEmail:
      case AuthErrorCode.userNotFound:
        return getMessage(code);
      default:
        return null;
    }
  }

  static String? getPasswordError(AuthErrorCode code) {
    switch (code) {
      case AuthErrorCode.weakPassword:
      case AuthErrorCode.wrongPassword:
        return getMessage(code);
      default:
        return null;
    }
  }

  static String? getUsernameError(AuthErrorCode code) {
    switch (code) {
      case AuthErrorCode.invalidUsername:
        return getMessage(code);
      default:
        return null;
    }
  }
}
