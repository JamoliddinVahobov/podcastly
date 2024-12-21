// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_event.dart';
import 'package:podcast_app/features/auth/logic/auth_state.dart';
import 'package:podcast_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:podcast_app/features/auth/presentation/widgets/custom_text_field.dart';

import '../../../../../core/helpers/helpers.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final FocusNode passwordFocusNode = FocusNode();

  bool obscurePassword = true;
  bool isLoading = false;

  String? emailError;
  String? passwordError;
  String? usernameError;

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is EmailVerificationRequired) {
                Navigator.pushNamed(context, '/verification');
              } else if (state is AuthError) {
                if (state.source == 'signup_error') {
                  emailError = state.emailError;
                  passwordError = state.passwordError;
                  usernameError = state.usernameError;
                  if (state.message ==
                      'Something went wrong, please try again.') {
                    Helpers.showSnackbar(
                      'Something went wrong, please try again.',
                      context,
                    );
                  }
                }
                if (state.source == 'signup_timeout') {
                  Helpers.showSnackbar(
                    'The signup request took too long. Please try again.',
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
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.06,
                    ),
                    CustomTextField(
                      controller: usernameController,
                      validatorType: 'username',
                      label: 'Username',
                      hint: 'Enter your username',
                      errorText: usernameError,
                      onChanged: (_) {
                        setState(() {
                          usernameError = null;
                        });
                      },
                    ),
                    CustomTextField(
                      controller: emailController,
                      validatorType: 'email',
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      onChanged: (_) {
                        setState(() {
                          emailError = null;
                        });
                      },
                    ),
                    CustomTextField(
                      controller: passwordController,
                      validatorType: 'password',
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: obscurePassword,
                      focusNode: passwordFocusNode,
                      suffixIcon: passwordFocusNode.hasFocus
                          ? IconButton(
                              icon: Icon(obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            )
                          : null,
                      errorText: passwordError,
                      onChanged: (_) {
                        setState(() {
                          passwordError = null;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    if (state is AuthLoading)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                    else
                      CustomButton(
                        label: 'Sign up',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final String email = emailController.text.trim();
                            final String password =
                                passwordController.text.trim();
                            final username = usernameController.text.trim();
                            context.read<AuthBloc>().add(
                                SignupRequested(email, password, username));
                          }
                        },
                        colors: [Colors.green.shade700, Colors.green.shade600],
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Log in',
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
