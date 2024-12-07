part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayEpisode extends AudioPlayerEvent {
  final String audioUrl;
  final Map<String, dynamic> episode;
  final Map<String, dynamic> podcast;

  const PlayEpisode(
      {required this.audioUrl, required this.episode, required this.podcast});

  @override
  List<Object?> get props => [audioUrl, episode, podcast];
}

class PauseEpisode extends AudioPlayerEvent {}

class ResumeEpisode extends AudioPlayerEvent {}

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
