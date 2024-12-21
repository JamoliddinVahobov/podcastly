import 'package:flutter/material.dart';
import 'package:podcast_app/features/podcast_details/presentation/home_page.dart';
import '../../features/auth/presentation/auth_check_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/signup_page.dart';
import '../../features/auth/presentation/verification_page.dart';
import '../../features/auth/presentation/welcome_page.dart';
import '../widgets/bottom_nav_bar.dart';

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
