import 'package:get_it/get_it.dart';
import 'package:podcast_app/core/services/token_management_service.dart';
import 'package:podcast_app/features/episode_details/data/datasources/remote_episode_source.dart';
import 'package:podcast_app/features/episode_details/data/repositories/episode_repository_impl.dart';
import 'package:podcast_app/features/episode_details/domain/repositories/episode_repository.dart';
import 'package:podcast_app/features/episode_details/domain/usecases/episode_usecase.dart';
import 'package:podcast_app/features/podcast_details/data/repositories/podcast_repository_impl.dart';
import 'package:podcast_app/features/podcast_details/domain/usecases/podcast_usecase.dart';
import '../../features/podcast_details/data/datasources/remote_podcast_source.dart';
import '../../features/podcast_details/domain/repositories/podcast_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Core Services
  getIt.registerLazySingleton(() => TokenManagementService());

  // Data Sources
  getIt.registerLazySingleton(() => RemotePodcastSource(getIt()));
  getIt.registerLazySingleton(() => RemoteEpisodeSource(getIt()));

  // Repositories
  getIt.registerLazySingleton<PodcastRepository>(
      () => PodcastRepositoryImpl(remotePodcastSource: getIt()));

  getIt.registerLazySingleton<EpisodeRepository>(
      () => EpisodeRepositoryImpl(remoteEpisodeSource: getIt()));

  // Use Cases
  getIt.registerLazySingleton(() => FetchPodcastsUsecase(getIt()));
  getIt.registerLazySingleton(() => FetchEpisodesUsecase(getIt()));
}
