part of 'podcast_details_bloc.dart';

class PodcastDetailsState extends Equatable {
  final Map<String, dynamic>? podcast;
  final List<Map<String, dynamic>> episodes;
  final bool isLoading;
  final String? error;

  const PodcastDetailsState({
    this.podcast,
    this.episodes = const [],
    this.isLoading = false,
    this.error,
  });

  PodcastDetailsState copyWith({
    Map<String, dynamic>? podcast,
    List<Map<String, dynamic>>? episodes,
    bool? isLoading,
    String? error,
  }) {
    return PodcastDetailsState(
      podcast: podcast ?? this.podcast,
      episodes: episodes ?? this.episodes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [podcast, episodes, isLoading, error];
}
