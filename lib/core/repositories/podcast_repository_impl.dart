import '../models/episode_model.dart';
import '../models/podcast_model.dart';
import '../services/pocast_service_impl.dart';
import 'abstract_podcast_repository.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastServiceImpl _spotifyService;

  const PodcastRepositoryImpl({
    required PodcastServiceImpl spotifyService,
  }) : _spotifyService = spotifyService;

  @override
  Future<List<Podcast>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    return await _spotifyService.fetchPodcasts(
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<List<Episode>> fetchEpisodes(
    String showId, {
    required int offset,
    required int limit,
  }) async {
    return await _spotifyService.fetchEpisodes(
      showId,
      offset: offset,
      limit: limit,
    );
  }
}
