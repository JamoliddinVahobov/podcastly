part of 'podcast_details_bloc.dart';

abstract class PodcastDetailsEvent extends Equatable {
  const PodcastDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadPodcastDetails extends PodcastDetailsEvent {
  final String podcastId;

  const LoadPodcastDetails(this.podcastId);

  @override
  List<Object> get props => [podcastId];
}

class LoadMoreEpisodes extends PodcastDetailsEvent {
  final String podcastId;
  const LoadMoreEpisodes(this.podcastId);
}
