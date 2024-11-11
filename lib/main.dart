import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/firebase_options.dart';
import 'package:podcast_app/logic/bloc/auth_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_state.dart';
import 'package:podcast_app/presentation/app_router/app_router.dart';
import 'package:podcast_app/presentation/auth%20pages/initial_page.dart';
import 'package:podcast_app/presentation/pages/podcasts_page.dart';

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
        title: 'Podcast app',
        home: InitialPage(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const PodcastsPage();
        } else {
          return const AuthPages();
        }
      },
    );
  }
}
