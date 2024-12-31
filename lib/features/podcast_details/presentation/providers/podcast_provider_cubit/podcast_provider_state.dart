part of 'podcast_provider_cubit.dart';

class PodcastProviderState extends Equatable {
  final List<Podcast> podcasts;
  final bool hasReachedMax;
  final bool isLoading;

  const PodcastProviderState({
    this.podcasts = const [],
    this.hasReachedMax = false,
    this.isLoading = false,
  });

  PodcastProviderState copyWith({
    List<Podcast>? podcasts,
    bool? hasReachedMax,
    bool? isLoading,
  }) {
    return PodcastProviderState(
      podcasts: podcasts ?? this.podcasts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [podcasts, hasReachedMax, isLoading];
}
