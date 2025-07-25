import 'package:podcast_app/features/episode_details/data/datasources/remote/remote_episode_source.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final RemoteEpisodeSource _remoteEpisodeSource;

  EpisodeRepositoryImpl({
    required RemoteEpisodeSource remoteEpisodeSource,
  }) : _remoteEpisodeSource = remoteEpisodeSource;
  @override
  Future<List<Episode>> fetchEpisodes(String showId,
      {required int offset, required int limit}) async {
    final models = await _remoteEpisodeSource.fetchEpisodes(showId,
        offset: offset, limit: limit);
    return models.map((model) => model.toEntity()).toList();
  }
}
