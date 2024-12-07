import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/spotify_service.dart';
part 'podcast_list_event.dart';
part 'podcast_list_state.dart';

class PodcastListBloc extends Bloc<PodcastListEvent, PodcastListState> {
  final int _limit = 21;
  int _offset = 0;

  PodcastListBloc() : super(const PodcastListState()) {
    on<LoadPodcasts>(_onLoadPodcasts);
    on<LoadMorePodcasts>(_onLoadMorePodcasts);
    on<RefreshPodcasts>(_onRefreshPodcasts);
  }

  Future<void> _onLoadPodcasts(
      LoadPodcasts event, Emitter<PodcastListState> emit) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final podcasts = await SpotifyService.fetchPodcasts(
        offset: _offset,
        limit: _limit,
      );

      emit(PodcastListState(
        podcasts: podcasts,
        hasReachedMax: podcasts.length < _limit,
        isLoading: false,
      ));

      _offset += _limit;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
      ));
      print('Error loading podcasts: $e');
    }
  }

  Future<void> _onLoadMorePodcasts(
      LoadMorePodcasts event, Emitter<PodcastListState> emit) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final podcasts = await SpotifyService.fetchPodcasts(
        offset: _offset,
        limit: _limit,
      );

      emit(PodcastListState(
        podcasts: List.of(state.podcasts)..addAll(podcasts),
        hasReachedMax: podcasts.length < _limit,
        isLoading: false,
      ));

      _offset += _limit;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
      ));
      print('Error loading more podcasts: $e');
    }
  }

  Future<void> _onRefreshPodcasts(
      RefreshPodcasts event, Emitter<PodcastListState> emit) async {
    _offset = 0;
    emit(const PodcastListState());
    add(LoadPodcasts());
  }
}
