import 'package:get_it/get_it.dart';
import 'package:podcast_app/features/podcast_details/data/services/token_management_service.dart';
import '../../features/podcast_details/data/repositories/abstract_podcast_repository.dart';
import '../../features/podcast_details/data/services/spotify_service.dart';
import '../../features/podcast_details/data/repositories/podcast_repository_impl.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final tokenService = TokenManagementService();
  getIt.registerLazySingleton(() => SpotifyService(tokenService));
  getIt.registerLazySingleton<PodcastRepository>(
      () => PodcastRepositoryImpl(spotifyService: getIt<SpotifyService>()));
}
