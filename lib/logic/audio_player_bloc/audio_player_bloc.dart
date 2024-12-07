import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerBloc() : super(const AudioPlayerState()) {
    // Register event handlers
    on<PlayEpisode>(_onPlayEpisode);
    on<PauseEpisode>(_onPauseEpisode);
    on<ResumeEpisode>(_onResumeEpisode);
    on<SeekEpisode>(_onSeekEpisode);
    on<UpdatePlaybackPosition>(_onUpdatePlaybackPosition);
    on<UpdatePlaybackDuration>(_onUpdatePlaybackDuration);

    // Listen to audio player events
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) async {
      final position = await _audioPlayer.getCurrentPosition();
      final duration = await _audioPlayer.getDuration(); // Add this line
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
      // Stop current playback if any
      await _audioPlayer.stop();

      // Play new episode
      final source = UrlSource(event.audioUrl);
      await _audioPlayer.play(source);

      // Update state
      emit(state.copyWith(
        playerState: PlayerState.playing,
        currentEpisode: event.episode,
        currentPodcast: event.podcast,
      ));
    } catch (e) {
      print('Error playing episode: $e');
    }
  }

  Future<void> _onPauseEpisode(
      PauseEpisode event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.pause();
    emit(state.copyWith(playerState: PlayerState.paused));
  }

  Future<void> _onResumeEpisode(
      ResumeEpisode event, Emitter<AudioPlayerState> emit) async {
    await _audioPlayer.resume();
    emit(state.copyWith(playerState: PlayerState.playing));
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

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
