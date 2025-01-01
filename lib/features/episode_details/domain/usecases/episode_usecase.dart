import 'package:podcast_app/features/episode_details/domain/entities/episode_entity.dart';
import 'package:podcast_app/features/episode_details/domain/repositories/episode_repository.dart';

class FetchEpisodesUsecase {
  final EpisodeRepository episodeRepository;

  FetchEpisodesUsecase(this.episodeRepository);
  Future<List<Episode>> fetchEpisodes(String showId,
      {required int offset, required int limit}) async {
    return await episodeRepository.fetchEpisodes(
      showId,
      limit: limit,
      offset: offset,
    );
  }
}
