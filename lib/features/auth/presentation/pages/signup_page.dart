import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_event.dart';
import 'package:podcast_app/features/auth/logic/auth_state.dart';
import 'package:podcast_app/features/auth/presentation/widgets/custom_text_field.dart';
import '../../../../../core/helpers/helpers.dart';
import '../widgets/auth_button.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

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

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context) {
    if (formKey.currentState!.validate()) {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();
      final String username = usernameController.text.trim();
      context.read<AuthBloc>().add(SignupRequested(email, password, username));
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
              if (state is EmailVerificationRequired) {
                Navigator.pushNamed(context, '/verification');
              } else if (state is AuthError) {
                if (state.emailError == null &&
                    state.passwordError == null &&
                    state.usernameError == null &&
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
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.06,
                    ),
                    CustomTextField(
                      controller: usernameController,
                      validatorType: 'username',
                      label: 'Username',
                      hint: 'Enter your username',
                      errorText:
                          state is AuthError ? state.usernameError : null,
                    ),
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
                      label: 'Sign up',
                      onPressed: () => _handleSignup(context),
                      colors: [Colors.green.shade700, Colors.green.shade600],
                      isLoading: state is AuthLoading,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
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
