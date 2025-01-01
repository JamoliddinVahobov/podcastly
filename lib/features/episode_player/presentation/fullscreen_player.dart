import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/image_size_enums.dart';
import '../../../core/helpers/helpers.dart';
import '../../episode_details/domain/entities/episode_entity.dart';
import '../../podcast_details/domain/entities/podcast_entity.dart';
import '../logic/audio_player_bloc/audio_player_bloc.dart';

class FullScreenPlayer extends StatelessWidget {
  final Episode episode;
  final Podcast podcast;

  const FullScreenPlayer({
    super.key,
    required this.episode,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildEpisodeImage(),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          episode.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildPlaybackSlider(context, audioState),
                        const SizedBox(height: 24),
                        _buildPlayerControls(context, audioState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeImage() {
    return episode.getImageForSize(ImageSize.large) != null &&
            episode.getImageForSize(ImageSize.large)!.isNotEmpty
        ? Image.network(
            episode.largeImageUrl!,
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          )
        : podcast.getImageForSize(ImageSize.large) != null &&
                podcast.getImageForSize(ImageSize.large)!.isNotEmpty
            ? Image.network(
                podcast.getImageForSize(ImageSize.large)!,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              )
            : const Center(
                child: Text(
                  'No image available for this episode',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
  }

  Widget _buildPlaybackSlider(
      BuildContext context, AudioPlayerState audioState) {
    return Column(
      children: [
        if (audioState.totalDuration != null)
          Slider(
            value: audioState.currentPosition.inSeconds.toDouble(),
            max: audioState.totalDuration!.inSeconds.toDouble(),
            onChanged: (value) {
              context.read<AudioPlayerBloc>().add(
                    SeekEpisode(
                      position: Duration(seconds: value.toInt()),
                    ),
                  );
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Helpers.formatDuration(audioState.currentPosition),
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (audioState.totalDuration != null)
                Text(
                  Helpers.formatDuration(audioState.totalDuration!),
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(
      BuildContext context, AudioPlayerState audioState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 32,
          onPressed: () {
            final newPosition =
                audioState.currentPosition - const Duration(seconds: 10);
            context.read<AudioPlayerBloc>().add(
                  SeekEpisode(position: newPosition),
                );
          },
        ),
        IconButton(
          icon: Icon(
            audioState.playerState == PlayerState.playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
          ),
          iconSize: 64,
          onPressed: () {
            final audioBloc = context.read<AudioPlayerBloc>();
            if (audioState.playerState == PlayerState.playing) {
              audioBloc.add(PauseEpisode(
                audioUrl: episode.audioUrl,
                episode: episode,
                podcast: podcast,
              ));
            } else if (audioState.playerState == PlayerState.paused) {
              audioBloc.add(
                ResumeEpisode(
                    audioUrl: episode.audioUrl,
                    episode: episode,
                    podcast: podcast),
              );
            } else {
              audioBloc.add(PlayEpisode(
                audioUrl: episode.audioUrl,
                episode: episode,
                podcast: podcast,
              ));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.forward_30),
          iconSize: 32,
          onPressed: () {
            final newPosition =
                audioState.currentPosition + const Duration(seconds: 30);
            context.read<AudioPlayerBloc>().add(
                  SeekEpisode(position: newPosition),
                );
          },
        ),
      ],
    );
  }
}
