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
                    context, 'podcasts', (route) => false);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message ?? 'Login failed.')),
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
                      errorText: _getPasswordError(context),
                    ),
                    SizedBox(height: 20),
                    _buildButton(
                      context: context,
                      label: 'Login',
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
                    _buildButton(
                      context: context,
                      label: 'Go to Signup page',
                      onPressed: () {
                        Navigator.pushNamed(context, 'signup');
                      },
                      colors: [Colors.green.shade700, Colors.green.shade600],
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


// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _see = true;
//   bool _isPasswordFocused = false;
//   final FocusNode _passwordFocusNode = FocusNode();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _passwordFocusNode.addListener(_onFocusChange);
//   }

//   void _onFocusChange() {
//     setState(() {
//       _isPasswordFocused = _passwordFocusNode.hasFocus;
//     });
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _passwordFocusNode.removeListener(_onFocusChange);
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             style: TextStyle(fontSize: 16, color: Colors.white),
//           ),
//           backgroundColor: Colors.grey[800],
//           behavior: SnackBarBehavior.floating,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _login() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       if (mounted) {
//         _showSnackBar('Please fill in all fields');
//       }
//       return;
//     }

//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       if (userCredential.user != null) {
//         if (userCredential.user!.emailVerified) {
//           if (mounted) {
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               'main',
//               (Route<dynamic> route) => false,
//             );
//           }
//         } else {
//           if (mounted) {
//             _showSnackBar('Please verify your email before logging in.');
//             await _auth.signOut();
//           }
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'wrong-password':
//           errorMessage = 'Email or password is incorrect.';
//           break;
//         case 'user-not-found':
//           errorMessage = 'No user found with this email.';
//           break;
//         case 'invalid-email':
//           errorMessage = 'This email address is not valid.';
//           break;
//         default:
//           errorMessage = 'An error occurred. Please try again.';
//           break;
//       }
//       if (mounted) {
//         _showSnackBar(errorMessage);
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('An unexpected error occurred. Please try again.');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 child: TextField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     labelStyle: TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hintText: "Enter your email here",
//                     hintStyle: TextStyle(
//                       color: Colors.grey[600],
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 17, horizontal: 15),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.grey[500]!,
//                         width: 2.0,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.blueAccent,
//                         width: 2.5,
//                       ),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.red,
//                         width: 2.0,
//                       ),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.redAccent,
//                         width: 2.5,
//                       ),
//                     ),
//                   ),
//                   autofillHints: null,
//                   autocorrect: false,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 child: TextField(
//                   controller: _passwordController,
//                   focusNode: _passwordFocusNode,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     labelStyle: TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                     hintText: "Enter your password here",
//                     hintStyle: TextStyle(
//                       color: Colors.grey[600],
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 17, horizontal: 15),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.grey[500]!,
//                         width: 2.0,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.blueAccent,
//                         width: 2.5,
//                       ),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.red,
//                         width: 2.0,
//                       ),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(
//                         color: Colors.redAccent,
//                         width: 2.5,
//                       ),
//                     ),
//                     suffixIcon: _isPasswordFocused
//                         ? IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 _see = !_see;
//                               });
//                             },
//                             icon: Icon(
//                                 _see ? Icons.visibility : Icons.visibility_off),
//                           )
//                         : null,
//                   ),
//                   autofillHints: null,
//                   autocorrect: false,
//                   obscureText: _see,
//                 ),
//               ),
//               SizedBox(height: 30),
//               GestureDetector(
//                 onTap: _login,
//                 child: Container(
//                   alignment: Alignment.center,
//                   height: 50,
//                   width: MediaQuery.of(context).size.width * 0.55,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.blue.shade700,
//                         Colors.blue.shade600,
//                         Colors.blue.shade400,
//                       ],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                   ),
//                   child: Text(
//                     'Login',
//                     style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 20,
//                         color: Colors.white),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               _buildButton(
//                 label: 'Go to Sign Up page',
//                 onPressed: () {
//                   Navigator.pushNamed(context, 'signup');
//                 },
//                 colors: [Colors.green.shade700, Colors.green.shade600],
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

//   Widget _buildButton({
//     required String label,
//     required VoidCallback onPressed,
//     required List<Color> colors,
//     required double widthFactor,
//     required double height,
//     required double fontSize,
//   }) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         alignment: Alignment.center,
//         height: height,
//         width: MediaQuery.of(context).size.width * widthFactor,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//           gradient: LinearGradient(
//             colors: colors,
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: fontSize,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
