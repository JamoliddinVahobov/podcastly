import 'package:podcast_app/features/podcast_details/domain/repositories/podcast_repository.dart';
import '../entities/podcast_entity.dart';

class FetchPodcastsUsecase {
  final PodcastRepository podcastRepository;

  FetchPodcastsUsecase(this.podcastRepository);
  Future<List<Podcast>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    return await podcastRepository.fetchPodcasts(
      offset: offset,
      limit: limit,
    );
  }
}
