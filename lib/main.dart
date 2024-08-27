// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:authentication_screens_example/firebase_options.dart';
import 'package:authentication_screens_example/login_page.dart';
import 'package:authentication_screens_example/main_screen.dart';
import 'package:authentication_screens_example/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Screens',
      home: const AuthScreens(),
      debugShowCheckedModeBanner: false,
      routes: {
        'login': (context) => LoginPage(),
        'signup': (context) => SignupPage(),
        'auth': (context) => AuthScreens(),
        'main': (context) => MainScreen(),
      },
    );
  }
}

class AuthScreens extends StatelessWidget {
  const AuthScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                'Hello',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 60,
                    color: Colors.green[800]),
              ),
            ),
            Text(
              'Welcome to our awesome app\nYou can Log in or Sign up here',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Colors.orange[800]),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'login');
              },
              child: Container(
                alignment: Alignment.center,
                height: 60,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade600,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'signup');
              },
              child: Container(
                alignment: Alignment.center,
                height: 60,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade700,
                      Colors.green.shade600,
                      Colors.green.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
