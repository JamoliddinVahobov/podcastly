import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;

  AuthBloc(this._auth) : super(AuthInitial()) {
    // Handling signup
    on<AuthSignupRequested>((event, emit) async {
      emit(AuthLoading(message: "Signing up..."));
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final User? user = userCredential.user;
        if (user != null) {
          await user.sendEmailVerification();
          emit(AuthAuthenticated(user));
        }
      } on FirebaseAuthException catch (e) {
        String? emailError;
        String? passwordError;

        switch (e.code) {
          case 'weak-password':
            passwordError = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            emailError = 'An account already exists with this email.';
            break;
          case 'invalid-email':
            emailError = 'This email address is not valid.';
            break;
          default:
            emailError = 'An unknown error occurred.';
            break;
        }
        emit(AuthError(emailError: emailError, passwordError: passwordError));
      } catch (e) {
        emit(AuthError(emailError: 'An unexpected error occurred.'));
      }
    });

    // Handling login
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading(message: "Logging in..."));
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final User? user = userCredential.user;
        if (user != null && user.emailVerified) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } on FirebaseAuthException catch (e) {
        String? emailError;
        String? passwordError;

        switch (e.code) {
          case 'user-not-found':
            emailError = 'No user found with this email.';
            break;
          case 'wrong-password':
            passwordError = 'Incorrect password.';
            break;
          case 'invalid-email':
            emailError = 'This email address is not valid.';
            break;
          default:
            emailError = 'An unknown error occurred.';
            break;
        }
        emit(AuthError(emailError: emailError, passwordError: passwordError));
      } catch (e) {
        emit(AuthError(emailError: 'An unexpected error occurred.'));
      }
    });

    // Handling logout
    on<AuthLogoutRequested>((event, emit) async {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    });

    // Checking authentication
    on<AuthCheckRequested>((event, emit) {
      final User? user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }
}
