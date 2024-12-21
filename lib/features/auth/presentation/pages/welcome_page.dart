import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
              'Welcome to Podcastly\nYou can Log in or Sign up here',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Colors.orange[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: 'Log in',
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              colors: [Colors.blue.shade700, Colors.blue.shade600],
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Sign up',
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              colors: [Colors.green.shade700, Colors.green.shade600],
            ),
          ],
        ),
      ),
    );
  }
}
