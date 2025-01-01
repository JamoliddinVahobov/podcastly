part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final PlayerState playerState;
  final Episode? currentEpisode;
  final Podcast? currentPodcast;
  final Duration currentPosition;
  final Duration? totalDuration;
  final Episode? nextEpisode;

  const AudioPlayerState({
    this.playerState = PlayerState.stopped,
    this.currentEpisode,
    this.currentPodcast,
    this.currentPosition = Duration.zero,
    this.totalDuration,
    this.nextEpisode,
  });

  AudioPlayerState copyWith({
    PlayerState? playerState,
    Episode? currentEpisode,
    Podcast? currentPodcast,
    Duration? currentPosition,
    Duration? totalDuration,
    Episode? nextEpisode,
  }) {
    return AudioPlayerState(
      playerState: playerState ?? this.playerState,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      nextEpisode: nextEpisode ?? this.nextEpisode,
    );
  }

  bool get isPlaying => playerState == PlayerState.playing;

  @override
  List<Object?> get props => [
        playerState,
        currentEpisode,
        currentPodcast,
        currentPosition,
        totalDuration,
        nextEpisode,
      ];
}
