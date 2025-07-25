import '../../models/podcast_model.dart';

abstract class RemotePodcastSource {
  Future<List<PodcastModel>> fetchPodcasts({
    required int offset,
    required int limit,
  });
}
