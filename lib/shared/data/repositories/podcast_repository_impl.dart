import '../../../features/podcast_details/data/models/podcast_model.dart';
import '../../../features/podcast_details/data/datasources/remote_podcast_source.dart';
import '../../../features/podcast_details/domain/repositories/podcast_repository.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final RemotePodcastSource _remotePodcastSource;

  const PodcastRepositoryImpl({
    required RemotePodcastSource remotePodcastSource,
  }) : _remotePodcastSource = remotePodcastSource;

  @override
  Future<List<Podcast>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    return await _remotePodcastSource.fetchPodcasts(
      offset: offset,
      limit: limit,
    );
  }
}
