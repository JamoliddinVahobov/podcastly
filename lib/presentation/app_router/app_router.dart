import 'package:flutter/material.dart';
import 'package:podcast_app/presentation/auth_pages/welcome_page.dart';
import 'package:podcast_app/presentation/auth_pages/login_page.dart';
import 'package:podcast_app/presentation/auth_pages/signup_page.dart';
import 'package:podcast_app/presentation/auth_pages/verification_page.dart';
import 'package:podcast_app/presentation/auth_pages/auth_check_page.dart';
import 'package:podcast_app/presentation/most_pages/home_page.dart';
import '../bottom_navigation_bar/bottom_nav_bar.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/bottombar':
        return MaterialPageRoute(builder: (_) => const TheBottomBar());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/verification':
        return MaterialPageRoute(builder: (_) => const VerificationPage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      default:
        return MaterialPageRoute(builder: (_) => const AuthCheckPage());
    }
  }
}
