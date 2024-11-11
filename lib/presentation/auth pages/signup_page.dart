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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                _showVerificationDialog(context);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message ??
                        'Something went wrong, please try again.'),
                  ),
                );
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
                      errorText: _getEmailError(context),
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
                      errorText: _getPasswordError(context),
                    ),
                    SizedBox(height: 20),
                    _buildButton(
                      context: context,
                      label: 'Sign Up',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final String email = emailController.text.trim();
                          final String password =
                              passwordController.text.trim();
                          context
                              .read<AuthBloc>()
                              .add(AuthSignupRequested(email, password));
                        }
                      },
                      colors: [Colors.green.shade700, Colors.green.shade600],
                    ),
                    SizedBox(height: 20),
                    _buildButton(
                      context: context,
                      label: 'Go to Login page',
                      onPressed: () {
                        Navigator.pushNamed(context, 'login');
                      },
                      colors: [Colors.blue.shade700, Colors.blue.shade600],
                      widthFactor: 0.5,
                      height: 40,
                      fontSize: 15,
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'auth');
                      },
                      child: Text(
                        'Go to the initial page',
                        style: TextStyle(fontSize: 15),
                      ),
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

  String? _getEmailError(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is AuthError) {
      return state.emailError; // Show email error if exists
    }
    return null; // No error
  }

  String? _getPasswordError(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is AuthError) {
      return state.passwordError; // Show password error if exists
    }
    return null; // No error
  }

  Future<void> _showVerificationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verification Email Sent'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'A verification email has been sent to your email address.'),
                Text('Please check your inbox and follow the instructions.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, 'login', (route) => false);
              },
            ),
          ],
        );
      },
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
                borderSide: BorderSide(color: Colors.redAccent, width: 2.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field cannot be empty';
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


// // ignore_for_file: prefer_const_constructors
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FocusNode _passwordFocusNode = FocusNode();

//   bool _isPasswordVisible = true;
//   bool _isPasswordFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _passwordFocusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _passwordFocusNode.removeListener(_onFocusChange);
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   void _onFocusChange() {
//     setState(() {
//       _isPasswordFocused = _passwordFocusNode.hasFocus;
//     });
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: TextStyle(fontSize: 16)),
//         backgroundColor: Colors.grey[800],
//       ),
//     );
//   }

//   Future<void> _signUp() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       if (mounted) {
//         _showSnackbar('Please fill in all fields');
//       }
//       return;
//     }
//     try {
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final User? user = userCredential.user;
//       if (user != null) {
//         await user.sendEmailVerification();
//         if (mounted) {
//           _showSnackbar('Verification Email Sent. Please check your email.');
//           if (mounted) {
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               'login',
//               (Route<dynamic> route) => false,
//             );
//           }
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'weak-password':
//           errorMessage = 'The password provided is too weak.';
//           break;
//         case 'email-already-in-use':
//           errorMessage = 'An account already exists with this email.';
//           break;
//         case 'invalid-email':
//           errorMessage = 'This email address is not valid.';
//           break;
//         default:
//           errorMessage = 'An error occurred. Please try again.';
//           break;
//       }
//       if (mounted) {
//         _showSnackbar(errorMessage);
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackbar('An unexpected error occurred. Please try again.');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildTextField(
//                 controller: _emailController,
//                 label: 'Email',
//                 hint: 'Enter your email here',
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               _buildTextField(
//                 controller: _passwordController,
//                 label: 'Password',
//                 hint: 'Enter your password here',
//                 obscureText: _isPasswordVisible,
//                 focusNode: _passwordFocusNode,
//                 suffixIcon: _isPasswordFocused
//                     ? IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _isPasswordVisible = !_isPasswordVisible;
//                           });
//                         },
//                         icon: Icon(
//                           _isPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                       )
//                     : null,
//               ),
//               SizedBox(height: 20),
//               _buildButton(
//                 label: 'Sign up',
//                 onPressed: _signUp,
//                 colors: [
//                   Colors.green.shade700,
//                   Colors.green.shade600,
//                   Colors.green.shade400
//                 ],
//               ),
//               SizedBox(height: 20),
//               _buildButton(
//                 label: 'Go to Login page',
//                 onPressed: () {
//                   Navigator.pushNamed(context, 'login');
//                 },
//                 colors: [Colors.blue.shade700, Colors.blue.shade600],
//                 widthFactor: 0.5,
//                 height: 40,
//                 fontSize: 15,
//               ),
//               SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, 'auth');
//                 },
//                 child: Text(
//                   'Go to the initial page',
//                   style: TextStyle(fontSize: 15),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   required String hint,
  //   TextInputType keyboardType = TextInputType.text,
  //   bool obscureText = false,
  //   FocusNode? focusNode,
  //   Widget? suffixIcon,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10),
  //     child: TextField(
  //       controller: controller,
  //       keyboardType: keyboardType,
  //       obscureText: obscureText,
  //       focusNode: focusNode,
  //       style: TextStyle(
  //         fontSize: 16,
  //         color: Colors.black,
  //       ),
  //       decoration: InputDecoration(
  //         labelText: label,
  //         labelStyle: TextStyle(
  //           fontWeight: FontWeight.w500,
  //         ),
  //         hintText: hint,
  //         hintStyle: TextStyle(
  //           color: Colors.grey[600],
  //         ),
  //         contentPadding:
  //             const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: BorderSide(
  //             color: Colors.grey[500]!,
  //             width: 2.0,
  //           ),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: BorderSide(
  //             color: Colors.blueAccent,
  //             width: 2.5,
  //           ),
  //         ),
  //         errorBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: BorderSide(
  //             color: Colors.red,
  //             width: 2.0,
  //           ),
  //         ),
  //         focusedErrorBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: BorderSide(
  //             color: Colors.redAccent,
  //             width: 2.5,
  //           ),
  //         ),
  //         suffixIcon: suffixIcon,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildButton({
  //   required String label,
  //   required VoidCallback onPressed,
  //   required List<Color> colors,
  //   double widthFactor = 0.55,
  //   double height = 50,
  //   double fontSize = 20,
  // }) {
  //   return GestureDetector(
  //     onTap: onPressed,
  //     child: Container(
  //       alignment: Alignment.center,
  //       height: height,
  //       width: MediaQuery.of(context).size.width * widthFactor,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(30),
  //         gradient: LinearGradient(
  //           colors: colors,
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           fontWeight: FontWeight.w500,
  //           fontSize: fontSize,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }
// }
