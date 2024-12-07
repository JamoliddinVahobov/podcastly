part of 'podcast_list_bloc.dart';

class PodcastListState extends Equatable {
  final List<Map<String, dynamic>> podcasts;
  final bool hasReachedMax;
  final bool isLoading;

  const PodcastListState({
    this.podcasts = const [],
    this.hasReachedMax = false,
    this.isLoading = false,
  });

  PodcastListState copyWith({
    List<Map<String, dynamic>>? podcasts,
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
