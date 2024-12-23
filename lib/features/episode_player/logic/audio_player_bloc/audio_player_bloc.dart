// audio_player_bloc.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/core/models/podcast_model.dart';
import 'package:podcast_app/core/models/episode_model.dart';
part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerBloc() : super(const AudioPlayerState()) {
    on<PlayEpisode>(_onPlayEpisode);
    on<PauseEpisode>(_onPauseEpisode);
    on<ResumeEpisode>(_onResumeEpisode);
    on<SeekEpisode>(_onSeekEpisode);
    on<UpdatePlaybackPosition>(_onUpdatePlaybackPosition);
    on<UpdatePlaybackDuration>(_onUpdatePlaybackDuration);
    on<SkipToNextEpisode>(_onSkipToNextEpisode);
    on<GoBackToPreviousEpisode>(_onGoBackToPreviousEpisode);
    on<DismissMiniPlayer>(_onDismissMiniPlayer);

    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) async {
      final position = await _audioPlayer.getCurrentPosition();
      final duration = await _audioPlayer.getDuration();
      add(UpdatePlaybackPosition(
        position ?? Duration.zero,
        totalDuration: duration,
      ));
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      add(UpdatePlaybackPosition(position));
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      add(UpdatePlaybackDuration(duration));
    });
  }

  Future<void> _onPlayEpisode(
      PlayEpisode event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioPlayer.stop();
      final source = UrlSource(event.audioUrl);
      await _audioPlayer.play(source);

      emit(state.copyWith(
        playerState: PlayerState.playing,
        currentEpisode: event.episode,
        currentPodcast: event.podcast,
      ));
    } catch (e) {
      debugPrint('Error playing episode: $e');
    }
  }

  Future<void> _onSkipToNextEpisode(
      SkipToNextEpisode event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioPlayer.stop();
      final source = UrlSource(event.audioUrl);
      await _audioPlayer.play(source);

      emit(state.copyWith(
        playerState: PlayerState.playing,
        currentEpisode: event.episode,
        currentPodcast: event.podcast,
      ));
    } catch (e) {
      debugPrint('Error going to the next episode: $e');
    }
  }

  Future<void> _onGoBackToPreviousEpisode(
      GoBackToPreviousEpisode event, Emitter<AudioPlayerState> emit) async {}

  Future<void> _onResumeEpisode(
      ResumeEpisode event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.resume();
    emit(state.copyWith(playerState: PlayerState.playing));
  }

  Future<void> _onPauseEpisode(
      PauseEpisode event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.pause();
    emit(state.copyWith(playerState: PlayerState.paused));
  }

  Future<void> _onSeekEpisode(
      SeekEpisode event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.seek(event.position);
    emit(state.copyWith(currentPosition: event.position));
  }

  void _onUpdatePlaybackPosition(
      UpdatePlaybackPosition event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(
      currentPosition: event.position,
      totalDuration: event.totalDuration ?? state.totalDuration,
    ));
  }

  void _onUpdatePlaybackDuration(
      UpdatePlaybackDuration event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(totalDuration: event.duration));
  }

  Future<void> _onDismissMiniPlayer(
      DismissMiniPlayer event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.stop();
    emit(state.copyWith(isMiniPlayerDismissed: true));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
