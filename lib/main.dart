import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/firebase_options.dart';
import 'package:podcast_app/helpers/helpers.dart';
import 'package:podcast_app/logic/bloc/auth_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_state.dart';
import 'package:podcast_app/presentation/app_router/app_router.dart';
import 'package:podcast_app/presentation/auth%20pages/welcome_page.dart';
import 'logic/bloc/auth_event.dart';
import 'presentation/bottom_navigation_bar/bottom_nav_bar.dart';

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
    return BlocProvider(
      create: (context) => AuthBloc(FirebaseAuth.instance),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Podcastly',
        home: AuthCheck(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(AuthCheckRequested());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError && state.source == 'auth_check_error') {
          Helpers.showSnackbar(state.message, context);
        }
      },
      builder: (context, state) {
        if (state is AuthenticatedUser) {
          return const TheBottomBar();
        } else if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}
