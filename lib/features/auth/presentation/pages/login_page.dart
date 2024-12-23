// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_event.dart';
import 'package:podcast_app/features/auth/logic/auth_state.dart';
import '../../../../../core/helpers/helpers.dart';
import '../widgets/auth_button.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FocusNode passwordFocusNode = FocusNode();

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (formKey.currentState!.validate()) {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();
      context.read<AuthBloc>().add(LoginRequested(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthenticatedUser) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/bottombar', (route) => false);
              } else if (state is AuthError) {
                if (state.emailError == null &&
                    state.passwordError == null &&
                    state.message.isNotEmpty) {
                  Helpers.showSnackbar(state.message, context);
                }
              }
            },
            builder: (context, state) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AuthEmailField(
                      controller: emailController,
                      errorText: state is AuthError ? state.emailError : null,
                    ),
                    AuthPasswordField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      obscurePassword: obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      errorText:
                          state is AuthError ? state.passwordError : null,
                    ),
                    const SizedBox(height: 20),
                    AuthButton(
                      label: 'Log in',
                      onPressed: () => _handleLogin(context),
                      colors: [Colors.blue.shade700, Colors.blue.shade600],
                      isLoading: state is AuthLoading,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
