part of 'episode_provider_bloc.dart';

class EpisodeProviderState extends Equatable {
  final Podcast podcast;
  final List<Episode> episodes;
  final bool isLoading;
  final bool hasReachedMax;
  final int? currentOffset;
  final String? error;

  const EpisodeProviderState({
    required this.podcast,
    this.episodes = const [],
    this.isLoading = false,
    this.hasReachedMax = false,
    this.currentOffset = 0,
    this.error,
  });

  EpisodeProviderState copyWith({
    Podcast? podcast,
    List<Episode>? episodes,
    bool? isLoading,
    String? error,
    bool? hasReachedMax,
    int? currentOffset,
  }) {
    return EpisodeProviderState(
      podcast: podcast ?? this.podcast,
      episodes: episodes ?? this.episodes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

  @override
  List<Object?> get props => [
        podcast,
        episodes,
        isLoading,
        error,
        hasReachedMax,
        currentOffset,
      ];
}
