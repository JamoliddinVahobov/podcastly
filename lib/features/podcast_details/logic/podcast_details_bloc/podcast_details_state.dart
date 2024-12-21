part of 'podcast_details_bloc.dart';

class PodcastDetailsState extends Equatable {
  final Podcast podcast;
  final List<Episode> episodes;
  final bool isLoading;
  final String? error;
  final bool hasReachedMax;
  final int? currentOffset;

  const PodcastDetailsState({
    required this.podcast,
    this.episodes = const [],
    this.isLoading = false,
    this.error,
    this.hasReachedMax = false,
    this.currentOffset,
  });

  PodcastDetailsState copyWith({
    Podcast? podcast,
    List<Episode>? episodes,
    bool? isLoading,
    String? error,
    bool? hasReachedMax,
    int? currentOffset,
  }) {
    return PodcastDetailsState(
      podcast: podcast ?? this.podcast,
      episodes: episodes ?? this.episodes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
