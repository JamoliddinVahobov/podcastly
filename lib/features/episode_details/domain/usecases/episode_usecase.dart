import 'package:podcast_app/features/episode_details/data/models/episode_model.dart';
import 'package:podcast_app/features/episode_details/domain/repositories/episode_repository.dart';

class EpisodeUsecase {
  final EpisodeRepository episodeRepository;

  EpisodeUsecase(this.episodeRepository);
  Future<List<Episode>> fetchEpisodes(String showId,
      {required int offset, required int limit}) async {
    return await episodeRepository.fetchEpisodes(
      showId,
      limit: limit,
      offset: offset,
    );
  }
}
