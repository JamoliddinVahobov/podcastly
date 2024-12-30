part of 'podcast_list_cubit.dart';

class PodcastListState extends Equatable {
  final List<Podcast> podcasts;
  final bool hasReachedMax;
  final bool isLoading;

  const PodcastListState({
    this.podcasts = const [],
    this.hasReachedMax = false,
    this.isLoading = false,
  });

  PodcastListState copyWith({
    List<Podcast>? podcasts,
    bool? hasReachedMax,
    bool? isLoading,
  }) {
    return PodcastListState(
      podcasts: podcasts ?? this.podcasts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [podcasts, hasReachedMax, isLoading];
}
