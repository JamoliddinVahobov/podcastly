import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/firebase/firebase_options.dart';
import 'package:podcast_app/features/episode_player/logic/audio_player_bloc/audio_player_bloc.dart';
import 'package:podcast_app/features/auth/logic/auth_bloc.dart';
import 'package:podcast_app/core/navigation/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/dependency_injection/dependency_injection.dart';
import 'core/utils/screen_size_utils.dart';
import 'features/auth/presentation/pages/auth_check_page.dart';
import 'features/auth/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  await dotenv.load();
  runApp(const PodcastApp());
}

class PodcastApp extends StatelessWidget {
  const PodcastApp({super.key});
  @override
  Widget build(BuildContext context) {
    final authService = AuthService(FirebaseAuth.instance);
    ScreenSize.init(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authService),
        ),
        BlocProvider(
          create: (context) => AudioPlayerBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Podcastly',
        home: const AuthCheckPage(),
        theme: ThemeData.light().copyWith(
            elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
        )),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
