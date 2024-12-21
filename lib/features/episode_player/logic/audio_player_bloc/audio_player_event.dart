// audio_player_event.dart
part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayEpisode extends AudioPlayerEvent {
  final String audioUrl;
  final Episode episode;
  final Podcast podcast;

  const PlayEpisode({
    required this.audioUrl,
    required this.episode,
    required this.podcast,
  });

  @override
  List<Object?> get props => [audioUrl, episode, podcast];
}

class SkipToNextEpisode extends AudioPlayerEvent {
  final String audioUrl;
  final Episode episode;
  final Podcast podcast;

  const SkipToNextEpisode({
    required this.audioUrl,
    required this.episode,
    required this.podcast,
  });

  @override
  List<Object?> get props => [audioUrl, episode, podcast];
}

class GoBackToPreviousEpisode extends AudioPlayerEvent {
  final String audioUrl;
  final Episode episode;
  final Podcast podcast;
  final Episode currentEpisode;

  const GoBackToPreviousEpisode({
    required this.audioUrl,
    required this.episode,
    required this.podcast,
    required this.currentEpisode,
  });

  @override
  List<Object?> get props => [audioUrl, episode, podcast, currentEpisode];
}

class PauseEpisode extends AudioPlayerEvent {
  final String audioUrl;
  final Episode episode;
  final Podcast podcast;

  const PauseEpisode({
    required this.audioUrl,
    required this.episode,
    required this.podcast,
  });

  @override
  List<Object?> get props => [audioUrl, episode, podcast];
}

class ResumeEpisode extends AudioPlayerEvent {
  final String audioUrl;
  final Episode episode;
  final Podcast podcast;

  const ResumeEpisode({
    required this.audioUrl,
    required this.episode,
    required this.podcast,
  });

  @override
  List<Object?> get props => [audioUrl, episode, podcast];
}

class SeekEpisode extends AudioPlayerEvent {
  final Duration position;

  const SeekEpisode({required this.position});

  @override
  List<Object?> get props => [position];
}

class UpdatePlaybackPosition extends AudioPlayerEvent {
  final Duration position;
  final Duration? totalDuration;

  const UpdatePlaybackPosition(
    this.position, {
    this.totalDuration,
  });

  @override
  List<Object?> get props => [position, totalDuration];
}

class UpdatePlaybackDuration extends AudioPlayerEvent {
  final Duration duration;

  const UpdatePlaybackDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class DismissMiniPlayer extends AudioPlayerEvent {}
