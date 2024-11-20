import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final timeoutDuration = const Duration(seconds: 20);
  AuthBloc(this._auth) : super(AuthInitial()) {
    // Handling signup
    on<AuthSignupRequested>((event, emit) async {
      emit(AuthLoading(message: "Signing up..."));
      try {
        // Use Future.timeout to wrap the signup operation
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        )
            .timeout(timeoutDuration, onTimeout: () {
          throw TimeoutException('Signup request timed out');
        });

        final User? user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(event.username);
          await user.sendEmailVerification();
          emit(AuthEmailVerificationRequired(user));
        } else {
          emit(AuthError(
            message: 'Something went wrong, please try again.',
            source: 'signup_error',
          ));
        }
      } on TimeoutException catch (_) {
        emit(AuthError(
          message: 'The signup request took too long. Please try again.',
          source: 'signup_timeout',
        ));
      } on FirebaseAuthException catch (e) {
        String? emailError;
        String? passwordError;
        String? usernameError;
        String? message;

        switch (e.code) {
          case 'weak-password':
            passwordError = 'The password provided is too weak.';
            message = passwordError;
            break;
          case 'email-already-in-use':
            emailError = 'An account already exists with this email.';
            message = emailError;
            break;
          case 'invalid-email':
            emailError = 'This email address is not valid.';
            message = emailError;
            break;
          case 'too-many-requests':
            message = 'Too many requests. Please try again later.';
          case 'invalid-display-name':
            usernameError = 'The username is invalid.';
            message = usernameError;
            break;
          default:
            message = 'Something went wrong, please try again.';
            break;
        }
        emit(AuthError(
          emailError: emailError,
          passwordError: passwordError,
          usernameError: usernameError,
          message: message,
          source: 'signup_error',
        ));
      } catch (e) {
        emit(AuthError(
          message: 'Something went wrong, please try again.',
          source: 'signup_error',
        ));
      }
    });

    // Handling login
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading(message: "Logging in..."));
      try {
        // Validate fields before making request
        if (event.email.isEmpty || event.password.isEmpty) {
          emit(AuthError(
            message: 'Email and password cannot be empty.',
            source: 'login_error',
          ));
          return;
        }

        // Perform login
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final User? user = userCredential.user;
        if (user != null && user.emailVerified) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError(
            message: 'User is not verified or does not exist.',
            source: 'login_error',
          ));
        }
      } on FirebaseAuthException catch (e) {
        String? emailError;
        String? passwordError;
        String? message;

        switch (e.code) {
          case 'user-not-found':
            emailError = 'No user found with this email.';
            message = emailError;
            break;
          case 'wrong-password':
            passwordError = 'Incorrect password.';
            message = passwordError;
            break;
          case 'invalid-email':
            emailError = 'This email address is not valid.';
            message = emailError;
            break;
          case 'too-many-requests':
            message = 'Too many requests. Please try again later.';
            break;
          case 'network-request-failed':
            message = 'Network error, please check your connection.';
            break;
          default:
            message = 'Something went wrong, please try again.';
            break;
        }
        emit(AuthError(
          emailError: emailError,
          passwordError: passwordError,
          message: message,
          source: 'login_error',
        ));
      } on TimeoutException catch (_) {
        emit(AuthError(
          message: 'The login request took too long. Please try again.',
          source: 'login_timeout',
        ));
      } catch (e) {
        emit(AuthError(
          message: 'Something went wrong, please try again.',
          source: 'login_error',
        ));
      }
    });

    on<AuthResendVerificationEmail>((event, emit) async {
      emit(AuthLoading(message: "Resending verification email..."));
      try {
        await event.user.sendEmailVerification();
        emit(EmailResent(message: "Verification email has been resent."));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'too-many-requests') {
          emit(AuthError(
            message: 'You have made too many requests. Please try again later.',
            source: 'resend_verification_error',
          ));
        } else {
          emit(AuthError(
            message: 'Failed to resend verification email. Please try again.',
            source: 'resend_verification_error',
          ));
        }
      } catch (e) {
        emit(AuthError(
          message: 'An unexpected error occurred. Please try again later.',
          source: 'resend_verification_error',
        ));
      }
    });

    // Handling logout
    on<AuthLogoutRequested>((event, emit) async {
      try {
        await _auth.signOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(
          message: 'Something went wrong, please try again.',
          source: 'logout_error',
        ));
      }
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
