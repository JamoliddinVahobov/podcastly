part of 'episode_provider_bloc.dart';

abstract class EpisodeProviderEvent extends Equatable {
  const EpisodeProviderEvent();

  @override
  List<Object> get props => [];
}

class LoadEpisodes extends EpisodeProviderEvent {
  final String podcastId;

  const LoadEpisodes(this.podcastId);

  @override
  List<Object> get props => [podcastId];
}

class LoadMoreEpisodes extends EpisodeProviderEvent {
  final String podcastId;
  const LoadMoreEpisodes(this.podcastId);
}
