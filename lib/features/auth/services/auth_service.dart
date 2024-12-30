import 'package:firebase_auth/firebase_auth.dart';

import '../auth_exceptions/auth_exceptions.dart';
import '../auth_exceptions/exception_messages.dart';
import '../auth_exceptions/extension.dart';

class AuthService {
  final FirebaseAuth _auth;
  final Duration timeoutDuration;

  AuthService(this._auth, {this.timeoutDuration = const Duration(seconds: 20)});

  Future<User> signup(String email, String password, String username) async {
    try {
      final userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(timeoutDuration);

      final user = userCredential.user;
      if (user == null) throw const AuthException();

      await user.updateDisplayName(username);
      await user.sendEmailVerification();
      return user;
    } on FirebaseAuthException catch (e) {
      final errorCode = AuthErrorCodeX.fromString(e.code);
      throw SignupException(
        code: e.code,
        message: AuthErrorMessages.getMessage(errorCode),
        emailError: AuthErrorMessages.getEmailError(errorCode),
        passwordError: AuthErrorMessages.getPasswordError(errorCode),
        usernameError: AuthErrorMessages.getUsernameError(errorCode),
      );
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(timeoutDuration);

      final user = userCredential.user;
      if (user == null || !user.emailVerified) {
        throw const AuthException('User is not verified or does not exist');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      final errorCode = AuthErrorCodeX.fromString(e.code);
      throw LoginException(
        code: e.code,
        message: AuthErrorMessages.getMessage(errorCode),
        emailError: AuthErrorMessages.getEmailError(errorCode),
        passwordError: AuthErrorMessages.getPasswordError(errorCode),
      );
    }
  }

  Future<void> resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final errorCode = AuthErrorCodeX.fromString(e.code);
      throw AuthException(AuthErrorMessages.getMessage(errorCode));
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<User?> checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.getIdToken();
      return user;
    }
    return null;
  }
}
