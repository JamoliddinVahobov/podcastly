// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_event.dart';
import 'package:podcast_app/logic/bloc/auth_state.dart';

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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthEmailVerificationRequired) {
                Navigator.pushNamed(context, '/verification');
              } else if (state is AuthError) {
                // Check for a general signup error
                if (state.source == 'signup_error') {
                  emailError = state.emailError;
                  passwordError = state.passwordError;
                  usernameError = state.usernameError;
                  if (state.message ==
                      'Something went wrong, please try again.') {
                    _showSnackbar('Something went wrong, please try again.');
                  }
                }
                if (state.source == 'signup_timeout') {
                  // Display a timeout-specific message to the user
                  _showSnackbar(
                      'The signup request took too long. Please try again.');
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
                    _buildTextField(
                      controller: usernameController,
                      label: 'Username',
                      hint: 'Enter your username',
                      errorText: usernameError,
                      onChanged: (_) {
                        setState(() {
                          usernameError = null;
                        });
                      },
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      validatorType: 'email',
                      onChanged: (_) {
                        setState(() {
                          emailError = null;
                        });
                      },
                    ),
                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      validatorType: 'password',
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
                      _buildButton(
                        context: context,
                        label: 'Sign up',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final String email = emailController.text.trim();
                            final String password =
                                passwordController.text.trim();
                            final username = usernameController.text.trim();
                            context.read<AuthBloc>().add(
                                AuthSignupRequested(email, password, username));
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    FocusNode? focusNode,
    Widget? suffixIcon,
    String? errorText,
    String? validatorType,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
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
                borderSide: BorderSide(color: Colors.red, width: 2.5),
              ),
            ),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field cannot be empty';
              }
              if (validatorType == 'password' && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              if (validatorType == 'email' &&
                  !RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
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
