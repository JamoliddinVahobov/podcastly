import '../../data/models/podcast_model.dart';

abstract class PodcastRepository {
  Future<List<Podcast>> fetchPodcasts(
      {required int offset, required int limit});
}
