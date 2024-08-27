// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, 'auth', (Route<dynamic> route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showDialog('Error', 'Could not log out. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: PopupMenuButton(itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Logout'),
                          content: Text(
                            "Are you sure you want to log out",
                            style: TextStyle(fontSize: 17),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                                _logout(); // Call the logout function
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Log out'),
                ),
              ];
            }),
          )
        ],
      ),
      body: Center(
        child: Text(
          "Hello World",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
