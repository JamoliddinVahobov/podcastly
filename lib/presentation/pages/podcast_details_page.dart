import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/presentation/pages/fullscreen_player.dart';
import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/podcast_details_bloc/podcast_details_bloc.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> podcast;

  const DetailsPage({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PodcastDetailsBloc()..add(LoadPodcastDetails(podcast['id'])),
        ),
        BlocProvider.value(
          value: context.read<AudioPlayerBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(podcast['name']),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                podcast['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.fitHeight,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast['name'],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      podcast['publisher'],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      podcast['description'] ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Episodes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              BlocBuilder<PodcastDetailsBloc, PodcastDetailsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                    builder: (context, audioState) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.episodes.length,
                        itemBuilder: (context, index) {
                          final episode = state.episodes[index];
                          final isCurrentlyPlaying =
                              audioState.currentEpisode?['id'] == episode['id'];

                          return ListTile(
                            title: Text(
                              episode['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Released: ${episode['release_date']}',
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
                                  audioBloc.add(PauseEpisode());
                                } else {
                                  audioBloc.add(PlayEpisode(
                                    audioUrl: episode['audio_url'],
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
            ],
          ),
        ),
      ),
    );
  }
}
