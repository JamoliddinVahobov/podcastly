// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_event.dart';
import 'package:podcast_app/logic/bloc/auth_state.dart';

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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.grey[800],
      ),
    );
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
              if (state is AuthAuthenticated) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/podcasts', (route) => false);
              } else if (state is AuthError) {
                // Check for a general login error
                if (state.source == 'login_error') {
                  emailError = state.emailError;
                  passwordError = state.passwordError;
                  // Handle other generic error cases
                  if (state.message ==
                      'Something went wrong, please try again.') {
                    _showSnackbar('Something went wrong, please try again.');
                  }
                }
                // Handle timeout error
                else if (state.source == 'login_timeout') {
                  // Display a timeout-specific message to the user
                  _showSnackbar(
                      'The login request took too long. Please try again.');
                }
              }
            },
            builder: (context, state) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email here',
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      validator: _validateEmail,
                    ),
                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter your password here',
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
                      validator: _validatePassword,
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
                      _buildButton(
                        context: context,
                        label: 'Log in',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final String email = emailController.text.trim();
                            final String password =
                                passwordController.text.trim();
                            context
                                .read<AuthBloc>()
                                .add(AuthLoginRequested(email, password));
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    const emailPattern =
        r'^[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$';
    final regExp = RegExp(emailPattern);

    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _getEmailError(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is AuthError && state.source == 'login_error') {
      return state.emailError; // Show email error if exists
    }
    return null; // No error
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null; // No error
  }

  String? _getPasswordError(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is AuthError && state.source == 'login_error') {
      return state.passwordError; // Show password error if exists
    }
    return null; // No error
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    FocusNode? focusNode,
    Widget? suffixIcon,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        focusNode: focusNode,
        style: TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          errorText: errorText, // Display error text here
          contentPadding:
              const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[500]!, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.redAccent, width: 2.5),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required List<Color> colors,
    double widthFactor = 0.55,
    double height = 50,
    double fontSize = 20,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: MediaQuery.of(context).size.width * widthFactor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
