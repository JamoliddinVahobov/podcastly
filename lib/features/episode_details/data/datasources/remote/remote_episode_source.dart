import '../../models/episode_model.dart';

abstract class RemoteEpisodeSource {
  Future<List<EpisodeModel>> fetchEpisodes(
    String showId, {
    required int offset,
    required int limit,
  });
}
