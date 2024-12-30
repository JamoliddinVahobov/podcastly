import 'package:podcast_app/features/episode_details/data/datasources/remote_episode_source.dart';
import 'package:podcast_app/features/episode_details/data/models/episode_model.dart';

import '../../domain/repositories/episode_repository.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final RemoteEpisodeSource _remoteEpisodeSource;

  EpisodeRepositoryImpl({required RemoteEpisodeSource remoteEpisodeSource})
      : _remoteEpisodeSource = remoteEpisodeSource;
  @override
  Future<List<Episode>> fetchEpisodes(String showId,
      {required int offset, required int limit}) async {
    return await _remoteEpisodeSource.fetchEpisodes(showId,
        offset: offset, limit: limit);
  }
}
