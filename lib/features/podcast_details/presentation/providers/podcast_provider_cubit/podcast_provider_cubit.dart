import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/features/podcast_details/domain/entities/podcast_entity.dart';
import '../../../domain/usecases/podcast_usecase.dart';
part 'podcast_provider_state.dart';

class PodcastProviderCubit extends Cubit<PodcastProviderState> {
  final FetchPodcastsUsecase _fetchPodcastsUsecase;
  final int _limit = 21;
  int _offset = 0;

  PodcastProviderCubit({
    required FetchPodcastsUsecase fetchPodcastsUsecase,
  })  : _fetchPodcastsUsecase = fetchPodcastsUsecase,
        super(const PodcastProviderState());

  Future<void> loadInitialPodcasts() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final podcasts = await _fetchPodcastsUsecase.fetchPodcasts(
        offset: 0,
        limit: _limit,
      );

      emit(PodcastProviderState(
        podcasts: podcasts,
        hasReachedMax: podcasts.length < _limit,
        isLoading: false,
      ));

      _offset = _limit;
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
      debugPrint('Error loading podcasts: $e');
    }
  }

  Future<void> loadMorePodcasts() async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final morePodcasts = await _fetchPodcastsUsecase.fetchPodcasts(
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
      debugPrint('Error loading more podcasts: $e');
    }
  }

  Future<void> refreshPodcasts() async {
    _offset = 0;
    emit(const PodcastProviderState());
    await loadInitialPodcasts();
  }
}
