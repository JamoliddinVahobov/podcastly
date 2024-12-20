import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcast_app/models/podcast_model.dart';
import '../../repositories/abstract_podcast_repository.dart';
part 'podcast_list_state.dart';

class PodcastListCubit extends Cubit<PodcastListState> {
  final PodcastRepository _repository;
  final int _limit = 21;
  int _offset = 0;

  PodcastListCubit({
    required PodcastRepository repository,
  })  : _repository = repository,
        super(const PodcastListState());

  Future<void> loadInitialPodcasts() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final podcasts = await _repository.fetchPodcasts(
        offset: 0,
        limit: _limit,
      );

      emit(PodcastListState(
        podcasts: podcasts,
        hasReachedMax: podcasts.length < _limit,
        isLoading: false,
      ));

      _offset = _limit;
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
      print('Error loading podcasts: $e');
    }
  }

  Future<void> loadMorePodcasts() async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final morePodcasts = await _repository.fetchPodcasts(
        offset: _offset,
        limit: _limit,
      );

      if (morePodcasts.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, isLoading: false));
        return;
      }

      emit(state.copyWith(
        podcasts: List.of(state.podcasts)..addAll(morePodcasts),
        hasReachedMax: morePodcasts.length < _limit,
        isLoading: false,
      ));

      _offset += _limit;
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      print('Error loading more podcasts: $e');
    }
  }

  Future<void> refreshPodcasts() async {
    _offset = 0;
    emit(const PodcastListState());
    await loadInitialPodcasts();
  }
}
