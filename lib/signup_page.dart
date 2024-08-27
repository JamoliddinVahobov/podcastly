// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = true;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isPasswordFocused = _passwordFocusNode.hasFocus;
    });
  }

  Future<void> _showDialog(String title, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message, style: TextStyle(fontSize: 17)),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        _showDialog('Error occurred', 'Please fill in all fields');
      }
      return;
    }
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        if (mounted) {
          await _showDialog('Verification Email Sent',
              'Please check your email to verify your account.');
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'login',
              (Route<dynamic> route) => false,
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'This email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
          break;
      }
      if (mounted) {
        _showDialog('Error', errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showDialog('Error', 'An unexpected error occurred. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email here',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password here',
                obscureText: _isPasswordVisible,
                focusNode: _passwordFocusNode,
                suffixIcon: _isPasswordFocused
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 20),
              _buildButton(
                label: 'Sign up',
                onPressed: _signUp,
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade600,
                  Colors.green.shade400
                ],
              ),
              SizedBox(height: 20),
              _buildButton(
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        focusNode: focusNode,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[600],
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.grey[500]!,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2.5,
            ),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildButton({
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
