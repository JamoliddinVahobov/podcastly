import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/spotify_service.dart';
part 'podcast_details_event.dart';
part 'podcast_details_state.dart';

class PodcastDetailsBloc
    extends Bloc<PodcastDetailsEvent, PodcastDetailsState> {
  final int _limit = 30;

  PodcastDetailsBloc(Map<String, dynamic> initialPodcast)
      : super(PodcastDetailsState(podcast: initialPodcast)) {
    on<LoadPodcastDetails>(_onLoadPodcastDetails);
    on<LoadMoreEpisodes>(_onLoadMoreEpisodes);
  }

  Future<void> _onLoadPodcastDetails(
      LoadPodcastDetails event, Emitter<PodcastDetailsState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final episodes = await SpotifyService.fetchEpisodes(
        event.podcastId,
        offset: 0,
        limit: _limit,
      );

      emit(
        state.copyWith(
          episodes: episodes,
          isLoading: false,
          hasReachedMax: episodes.length < _limit,
          currentOffset: episodes.length,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      print('Error loading podcast details: $e');
    }
  }

  Future<void> _onLoadMoreEpisodes(
      LoadMoreEpisodes event, Emitter<PodcastDetailsState> emit) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final podcastId = event.podcastId;

      final moreEpisodes = await SpotifyService.fetchEpisodes(
        podcastId,
        offset: state.currentOffset!,
        limit: _limit,
      );

      final updatedEpisodes = [...state.episodes, ...moreEpisodes];

      emit(state.copyWith(
        episodes: updatedEpisodes,
        currentOffset: updatedEpisodes.length,
        hasReachedMax: moreEpisodes.length < _limit,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
      print('Error loading more podcast episodes: $e');
    }
  }
}
