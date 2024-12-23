import '../models/episode_model.dart';
import '../models/podcast_model.dart';

abstract class PocastService {
  Future<List<Podcast>> fetchPodcasts({
    required int offset,
    required int limit,
  });

  Future<List<Episode>> fetchEpisodes(
    String showId, {
    required int offset,
    required int limit,
  });
}
