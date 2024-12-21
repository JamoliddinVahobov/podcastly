// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_event.dart';
import 'package:podcast_app/features/auth/logic/auth_state.dart';

import '../../../../../core/helpers/helpers.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

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
    passwordFocusNode.addListener(() {
      setState(() {}); // Update UI when focus changes
    });
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  String? emailError;
  String? passwordError;

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
                // Check for a general login error
                if (state.source == 'login_error') {
                  emailError = state.emailError;
                  passwordError = state.passwordError;
                  // Handle other generic error cases
                  if (state.message ==
                      'Something went wrong, please try again.') {
                    Helpers.showSnackbar(
                      'Something went wrong, please try again.',
                      context,
                    );
                  }
                }
                // Handle timeout error
                else if (state.source == 'login_timeout') {
                  // Display a timeout-specific message to the user
                  Helpers.showSnackbar(
                    'The login request took too long. Please try again.',
                    context,
                  );
                }
              }
            },
            builder: (context, state) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email here',
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      validatorType: 'email',
                    ),
                    CustomTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter your password here',
                      obscureText: obscurePassword,
                      focusNode: passwordFocusNode,
                      suffixIcon: passwordFocusNode.hasFocus
                          ? IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            )
                          : null,
                      errorText: passwordError,
                      validatorType: 'password',
                    ),
                    SizedBox(height: 20),
                    if (state is AuthLoading)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    else
                      CustomButton(
                        label: 'Log in',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final String email = emailController.text.trim();
                            final String password =
                                passwordController.text.trim();
                            context
                                .read<AuthBloc>()
                                .add(LoginRequested(email, password));
                          }
                        },
                        colors: [Colors.blue.shade700, Colors.blue.shade600],
                      ),
                    SizedBox(height: 20),
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
