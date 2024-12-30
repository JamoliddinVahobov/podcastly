import 'package:get_it/get_it.dart';
import 'package:podcast_app/core/services/token_management_service.dart';
import '../../features/podcast_details/domain/repositories/podcast_repository.dart';
import '../../features/podcast_details/data/datasources/remote_podcast_source.dart';
import '../../shared/data/repositories/podcast_repository_impl.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final tokenService = TokenManagementService();
  getIt.registerLazySingleton(() => RemotePodcastSource(tokenService));
  getIt.registerLazySingleton<PodcastRepository>(() =>
      PodcastRepositoryImpl(remotePodcastSource: getIt<RemotePodcastSource>()));
}
