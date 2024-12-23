import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/core/models/podcast_model.dart';
import '../../../../core/models/episode_model.dart';
import '../../../../core/repositories/abstract_podcast_repository.dart';
part 'podcast_details_event.dart';
part 'podcast_details_state.dart';

class PodcastDetailsBloc
    extends Bloc<PodcastDetailsEvent, PodcastDetailsState> {
  final PodcastRepository _repository;
  final int _limit = 30;

  PodcastDetailsBloc(
    Podcast initialPodcasts, {
    required PodcastRepository repository,
  })  : _repository = repository,
        super(PodcastDetailsState(podcast: initialPodcasts)) {
    on<LoadPodcastDetails>(_onLoadPodcastDetails);
    on<LoadMoreEpisodes>(_onLoadMoreEpisodes);
  }

  Future<void> _onLoadPodcastDetails(
      LoadPodcastDetails event, Emitter<PodcastDetailsState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final episodesJson = await _repository.fetchEpisodes(
        event.podcastId,
        offset: 0,
        limit: _limit,
      );

      final episodes = List<Episode>.from(
        episodesJson.map((episodeJson) {
          debugPrint('Episode JSON: $episodeJson');
          if (episodeJson is Map<String, dynamic>) {
            return Episode.fromJson(episodeJson as Map<String, dynamic>);
          }
          throw const FormatException('Invalid episode format');
        }),
      );

      emit(state.copyWith(
        episodes: episodes,
        isLoading: false,
        hasReachedMax: episodes.length < _limit,
        currentOffset: episodes.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      debugPrint('Error loading podcast details: $e');
    }
  }

  Future<void> _onLoadMoreEpisodes(
      LoadMoreEpisodes event, Emitter<PodcastDetailsState> emit) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final moreEpisodesJson = await _repository.fetchEpisodes(
        event.podcastId,
        offset: state.currentOffset!,
        limit: _limit,
      );

      final moreEpisodes = List<Episode>.from(
        moreEpisodesJson.map((episodeJson) {
          if (episodeJson is Map<String, dynamic>) {
            return Episode.fromJson(episodeJson as Map<String, dynamic>);
          }
          throw const FormatException('Invalid episode format');
        }),
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
      debugPrint('Error loading more podcast episodes: $e');
    }
  }
}
