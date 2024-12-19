import '../models/episode_model.dart';
import '../models/podcast_model.dart';
import '../services/spotify_service.dart';
import 'abstract_repository.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final SpotifyService _spotifyService;

  const PodcastRepositoryImpl({
    required SpotifyService spotifyService,
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
