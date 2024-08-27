// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _see = true;
  bool _isPasswordFocused = false;
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isPasswordFocused = _passwordFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(
              message,
              style: TextStyle(fontSize: 17),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        _showDialog('Error', 'Please fill in all fields');
      }
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'main',
              (Route<dynamic> route) => false,
            );
          }
        } else {
          if (mounted) {
            _showDialog('Email Not Verified',
                'Please verify your email before logging in.');
            await _auth.signOut();
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Email or password is incorrect.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: "Enter your email here",
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 17, horizontal: 15),
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
                  ),
                  autofillHints: null,
                  autocorrect: false,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: "Enter your password here",
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 17, horizontal: 15),
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
                    suffixIcon: _isPasswordFocused
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _see = !_see;
                              });
                            },
                            icon: Icon(
                                _see ? Icons.visibility : Icons.visibility_off),
                          )
                        : null,
                  ),
                  autofillHints: null,
                  autocorrect: false,
                  obscureText: _see,
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: _login,
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade600,
                        Colors.blue.shade400,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildButton(
                label: 'Go to Sign Up page',
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
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required List<Color> colors,
    required double widthFactor,
    required double height,
    required double fontSize,
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
