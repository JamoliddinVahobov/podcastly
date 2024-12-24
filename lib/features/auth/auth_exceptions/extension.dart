import 'enums.dart';

extension AuthErrorCodeX on AuthErrorCode {
  static AuthErrorCode fromString(String code) {
    switch (code) {
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'email-already-in-use':
        return AuthErrorCode.emailInUse;
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      case 'invalid-display-name':
        return AuthErrorCode.invalidUsername;
      case 'user-not-found':
        return AuthErrorCode.userNotFound;
      case 'wrong-password':
        return AuthErrorCode.wrongPassword;
      case 'network-request-failed':
        return AuthErrorCode.networkError;
      default:
        return AuthErrorCode.unknown;
    }
  }
}
