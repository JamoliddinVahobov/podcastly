import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/core/dependency_injection/dependency_injection.dart';
import 'package:podcast_app/features/episode_details/domain/usecases/episode_usecase.dart';
import 'package:podcast_app/features/episode_player/presentation/fullscreen_player.dart';
import 'package:podcast_app/features/episode_player/presentation/mini_player.dart';
import 'package:podcast_app/core/utils/screen_size_utils.dart';
import 'package:podcast_app/features/podcast_details/domain/entities/podcast_entity.dart';
import '../../../../core/enums/image_size_enums.dart';
import '../../../episode_player/logic/audio_player_bloc/audio_player_bloc.dart';
import '../../../episode_details/presentation/providers/episode_provider_bloc/episode_provider_bloc.dart';

class PodcastDetailsPage extends StatelessWidget {
  final Podcast podcast;

  const PodcastDetailsPage({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    final episodesUsecase = getIt<FetchEpisodesUsecase>();
    return BlocProvider(
      create: (context) => EpisodeProviderBloc(
        podcast,
        episodesUsecase: episodesUsecase,
      )..add(LoadEpisodes(podcast.id)),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 235,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: ScreenSize.screenHeight * 0.04,
                        ),
                        child: Container(
                          height: ScreenSize.screenHeight * 0.25,
                          width: ScreenSize.screenWidth * 0.55,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                podcast.getImageForSize(ImageSize.medium) ??
                                    'No image for this podcast',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        if (podcast.publisher.isNotEmpty)
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(
                                text: 'Publisher: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: podcast.publisher,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                          ),
                        const SizedBox(height: 10),
                        if (podcast.description?.isNotEmpty ?? false)
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(
                                text: 'Description: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: podcast.description ??
                                    'No description for this podcast',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          'Episodes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<EpisodeProviderBloc, EpisodeProviderState>(
                  builder: (context, state) {
                    return SliverList.builder(
                      itemCount: state.hasReachedMax
                          ? state.episodes.length
                          : state.episodes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.episodes.length) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            context
                                .read<EpisodeProviderBloc>()
                                .add(LoadMoreEpisodes(podcast.id));
                          });
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final episode = state.episodes[index];

                        return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                          builder: (context, audioState) {
                            final isCurrentlyPlaying =
                                audioState.currentEpisode?.id == episode.id;

                            return ListTile(
                              title: Text(
                                episode.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Released in: ${episode.releaseDate}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isCurrentlyPlaying && audioState.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                ),
                                onPressed: () {
                                  final audioBloc =
                                      context.read<AudioPlayerBloc>();

                                  if (isCurrentlyPlaying &&
                                      audioState.isPlaying) {
                                    audioBloc.add(PauseEpisode(
                                      audioUrl: episode.audioUrl,
                                      episode: episode,
                                      podcast: podcast,
                                    ));
                                  } else if (audioState.playerState ==
                                      PlayerState.paused) {
                                    audioBloc.add(
                                      ResumeEpisode(
                                        audioUrl: episode.audioUrl,
                                        episode: episode,
                                        podcast: podcast,
                                      ),
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
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),
            BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
              builder: (context, audioState) {
                if (audioState.currentEpisode != null) {
                  return const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MiniPlayer(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
