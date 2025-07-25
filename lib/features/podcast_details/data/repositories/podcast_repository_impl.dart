import '../../domain/entities/podcast_entity.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../datasources/remote/remote_podcast_source.dart';

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
    final models = await _remotePodcastSource.fetchPodcasts(
      offset: offset,
      limit: limit,
    );
    return models.map((model) => model.toEntity()).toList();
  }
}
