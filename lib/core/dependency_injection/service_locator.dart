import 'package:get_it/get_it.dart';
import 'package:podcast_app/core/services/token_management_service.dart';
import '../repositories/abstract_podcast_repository.dart';
import '../services/pocast_service_impl.dart';
import '../repositories/podcast_repository_impl.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final tokenService = TokenManagementService();
  getIt.registerLazySingleton(() => PodcastServiceImpl(tokenService));
  getIt.registerLazySingleton<PodcastRepository>(
      () => PodcastRepositoryImpl(spotifyService: getIt<PodcastServiceImpl>()));
}
