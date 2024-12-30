import '../../data/models/episode_model.dart';

abstract class EpisodeRepository {
  Future<List<Episode>> fetchEpisodes(String showId,
      {required int offset, required int limit});
}
