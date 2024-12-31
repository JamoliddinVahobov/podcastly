import 'package:podcast_app/features/podcast_details/data/models/podcast_model.dart';
import 'package:podcast_app/features/podcast_details/domain/repositories/podcast_repository.dart';

class FetchPodcastsUsecase {
  final PodcastRepository podcastRepository;

  FetchPodcastsUsecase(this.podcastRepository);
  Future<List<Podcast>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    return await podcastRepository.fetchPodcasts(
      limit: limit,
      offset: offset,
    );
  }
}
