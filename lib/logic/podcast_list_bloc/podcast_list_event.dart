part of 'podcast_list_bloc.dart';

abstract class PodcastListEvent extends Equatable {
  const PodcastListEvent();

  @override
  List<Object> get props => [];
}

class LoadPodcasts extends PodcastListEvent {}

class LoadMorePodcasts extends PodcastListEvent {}

class RefreshPodcasts extends PodcastListEvent {}
