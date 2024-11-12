import 'package:flutter/material.dart';
import 'package:podcast_app/main.dart';
import 'package:podcast_app/presentation/auth%20pages/welcome_page.dart';
import 'package:podcast_app/presentation/auth%20pages/login_page.dart';
import 'package:podcast_app/presentation/auth%20pages/signup_page.dart';
import 'package:podcast_app/presentation/auth%20pages/verification_page.dart';
import 'package:podcast_app/presentation/pages/podcasts_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/podcasts':
        return MaterialPageRoute(builder: (_) => const PodcastsPage());
      case '/verification':
        return MaterialPageRoute(builder: (_) => const VerificationPage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      default:
        return MaterialPageRoute(builder: (_) => const AuthCheck());
    }
  }
}
