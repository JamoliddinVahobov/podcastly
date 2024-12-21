import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/features/podcast_details/data/models/episode_model.dart';
import 'package:podcast_app/features/podcast_details/data/models/podcast_model.dart';
import 'package:podcast_app/features/episode_player/presentation/fullscreen_player.dart';

import '../logic/audio_player_bloc/audio_player_bloc.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        final episode = audioState.currentEpisode!;
        final podcast = audioState.currentPodcast!;

        if (audioState.currentEpisode != null) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenPlayer(
                    podcast: podcast,
                    episode: episode,
                  ),
                ),
              );
            },
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildEpisodeImage(episode, podcast),
                  Expanded(
                    child: _buildEpisodeInfo(episode),
                  ),
                  _buildPlayerControls(context, audioState),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildEpisodeImage(Episode episode, Podcast podcast) {
    String imageUrl = episode.imageUrl ?? podcast.imageUrl ?? '';

    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildNoImagePlaceholder();
            },
          )
        : _buildNoImagePlaceholder();
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      child: const Text('No Image', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildEpisodeInfo(Episode episode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            episode.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(
      BuildContext context, AudioPlayerState audioState) {
    final episode = audioState.currentEpisode!;
    final podcast = audioState.currentPodcast!;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
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
                ? Icons.pause
                : Icons.play_arrow,
          ),
          onPressed: () {
            final audioBloc = context.read<AudioPlayerBloc>();
            if (audioState.playerState == PlayerState.playing) {
              audioBloc.add(PauseEpisode(
                audioUrl: episode.imageUrl!,
                episode: episode,
                podcast: podcast,
              ));
            } else if (audioState.playerState == PlayerState.paused) {
              audioBloc.add(ResumeEpisode(
                audioUrl: episode.imageUrl!,
                episode: episode,
                podcast: podcast,
              ));
            } else {
              // This should not happen in MiniPlayer, but kept for completeness

              audioBloc.add(PlayEpisode(
                audioUrl: episode.imageUrl!,
                episode: episode,
                podcast: podcast,
              ));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.forward_30),
          onPressed: () {
            final newPosition =
                audioState.currentPosition + const Duration(seconds: 30);
            context.read<AudioPlayerBloc>().add(
                  SeekEpisode(position: newPosition),
                );
          },
        ),
        IconButton(
          onPressed: () {
            context.read<AudioPlayerBloc>().add(
                  DismissMiniPlayer(),
                );
          },
          icon: const Icon(Icons.cancel),
        ),
      ],
    );
  }
}
