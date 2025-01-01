import '../entities/podcast_entity.dart';

abstract class PodcastRepository {
  Future<List<Podcast>> fetchPodcasts(
      {required int offset, required int limit});
}
