import 'package:get_it/get_it.dart';
import 'package:podcast_app/services/token_management_service.dart';
import '../repositories/abstract_repository.dart';
import '../services/spotify_service.dart';
import '../repositories/podcast_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final tokenService = TokenManagementService();
  getIt.registerLazySingleton(() => SpotifyService(tokenService));
  getIt.registerLazySingleton<PodcastRepository>(
      () => PodcastRepositoryImpl(spotifyService: getIt<SpotifyService>()));
}
