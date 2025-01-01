import 'package:podcast_app/features/episode_details/domain/entities/episode_entity.dart';

abstract class EpisodeRepository {
  Future<List<Episode>> fetchEpisodes(String showId,
      {required int offset, required int limit});
}
