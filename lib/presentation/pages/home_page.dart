import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/presentation/auth%20pages/welcome_page.dart';
import 'package:podcast_app/presentation/pages/mini_player.dart';

import '../../logic/audio_player_bloc/audio_player_bloc.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/podcast_list_bloc/podcast_list_bloc.dart';
import 'podcast_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UnauthenticatedUser) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const WelcomePage()),
              );
            }
          },
        ),
      ],
      child: BlocProvider(
        create: (context) => PodcastListBloc()..add(LoadPodcasts()),
        child: Scaffold(
          body: BlocBuilder<PodcastListBloc, PodcastListState>(
            builder: (context, state) {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      context.read<PodcastListBloc>().add(RefreshPodcasts());
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 16, // Adjust based on player state if needed
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount:
                          state.podcasts.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.podcasts.length) {
                          context
                              .read<PodcastListBloc>()
                              .add(LoadMorePodcasts());
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return _buildPodcastCard(
                            context, state.podcasts[index]);
                      },
                    ),
                  ),
                  // MiniPlayer would be added here conditionally based on audio player state
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastCard(BuildContext context, Map<String, dynamic> podcast) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(podcast: podcast),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                podcast['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast['publisher'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class DetailsPage extends StatefulWidget {
//   final Map<String, dynamic> podcast;
//   final AudioPlayer player;
//   final Function(Map<String, dynamic>) onPlayEpisode;

//   const DetailsPage({
//     Key? key,
//     required this.podcast,
//     required this.player,
//     required this.onPlayEpisode,
//   }) : super(key: key);

//   @override
//   _DetailsPageState createState() => _DetailsPageState();
// }

// class _DetailsPageState extends State<DetailsPage> {
//   List<Map<String, dynamic>> episodes = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchEpisodes();
//   }

//   Future<void> _fetchEpisodes() async {
//     try {
//       final fetchedEpisodes =
//           await SpotifyService.fetchEpisodes(widget.podcast['id']);
//       setState(() {
//         episodes = fetchedEpisodes;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching episodes: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   bool isPlaying = false; // Track the play state

//   void onPlayPause(Map<String, dynamic> episode) async {
//     setState(() {
//       isPlaying = !isPlaying;
//     });

//     if (isPlaying) {
//       final source = UrlSource(episode['audio_url']);
//       await widget.player.play(source);
//     } else {
//       await widget.player.pause();
//     }
//   }

//   void onSeekBackward() {
//     widget.player
//         .seek(const Duration(seconds: -10)); // Seek backward by 10 seconds
//   }

//   void onSeekForward() {
//     widget.player
//         .seek(const Duration(seconds: 10)); // Seek forward by 10 seconds
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.podcast['name']),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(
//               widget.podcast['image'],
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.fitHeight,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.podcast['name'],
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     widget.podcast['publisher'],
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     widget.podcast['description'] ?? '',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Episodes',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ],
//               ),
//             ),
//             if (isLoading)
//               const Center(child: CircularProgressIndicator())
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: episodes.length,
//                 itemBuilder: (context, index) {
//                   final episode = episodes[index];
//                   return ListTile(
//                     title: Text(
//                       episode['name'],
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     subtitle: Text(
//                       'Released: ${episode['release_date']}',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                     trailing: IconButton(
//                       icon: Icon(
//                         isPlaying
//                             ? Icons.pause_circle_filled
//                             : Icons.play_circle_filled,
//                       ),
//                       onPressed: () async {
//                         final source = UrlSource(episode['audio_url']);
//                         await widget.player.play(source);
//                       },
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => FullScreenPlayer(
//                             podcast: widget.podcast,
//                             episode: episode,
//                             player: widget.player,
//                             isPlaying:
//                                 isPlaying, // Pass the current playing state
//                             onPlayPause: () => onPlayPause(
//                                 episode), // Pass the play/pause function
//                             onSeekBackward:
//                                 onSeekBackward, // Pass the seek backward function
//                             onSeekForward:
//                                 onSeekForward, // Pass the seek forward function
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FullScreenPlayer extends StatelessWidget {
//   final Map<String, dynamic> episode;
//   final AudioPlayer player;
//   final bool isPlaying;
//   final VoidCallback onPlayPause;
//   final VoidCallback onSeekBackward;
//   final VoidCallback onSeekForward;
//   final Map<String, dynamic> podcast;

//   const FullScreenPlayer({
//     super.key,
//     required this.episode,
//     required this.podcast,
//     required this.player,
//     required this.isPlaying,
//     required this.onPlayPause,
//     required this.onSeekBackward,
//     required this.onSeekForward,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).scaffoldBackgroundColor,
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: SingleChildScrollView(
//               controller: scrollController,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: episode['image'] != null &&
//                                   episode['image']!.isNotEmpty
//                               ? Image.network(
//                                   episode['image']!,
//                                   width: double.infinity,
//                                   height: 300,
//                                   fit: BoxFit.cover,
//                                 )
//                               : podcast['image'] != null &&
//                                       podcast['image']!.isNotEmpty
//                                   ? Image.network(
//                                       podcast['image']!,
//                                       width: double.infinity,
//                                       height: 300,
//                                       fit: BoxFit.cover,
//                                     )
//                                   : const Center(
//                                       child: Text(
//                                         'No image available for this podcast channel',
//                                         style: TextStyle(
//                                             fontStyle: FontStyle.italic,
//                                             color: Colors.grey),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           episode['name'],
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           episode['show'] ?? '',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         StreamBuilder<Duration>(
//                           stream:
//                               player.onPositionChanged, // Use onPositionChanged
//                           builder: (context, positionSnapshot) {
//                             final position =
//                                 positionSnapshot.data ?? Duration.zero;
//                             return FutureBuilder<Duration?>(
//                               future: player.getDuration(), // Get duration here
//                               builder: (context, durationSnapshot) {
//                                 // Check if duration is null and provide a default value
//                                 final duration =
//                                     durationSnapshot.data ?? Duration.zero;

//                                 return Column(
//                                   children: [
//                                     Slider(
//                                       value: position.inSeconds.toDouble(),
//                                       max: duration.inSeconds.toDouble(),
//                                       onChanged: (value) {
//                                         player.seek(
//                                             Duration(seconds: value.toInt()));
//                                       },
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 24),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             _formatDuration(position),
//                                             style: TextStyle(
//                                                 color: Colors.grey[600]),
//                                           ),
//                                           Text(
//                                             _formatDuration(duration),
//                                             style: TextStyle(
//                                                 color: Colors.grey[600]),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.replay_10),
//                               iconSize: 32,
//                               onPressed: onSeekBackward,
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 isPlaying
//                                     ? Icons.pause_circle_filled
//                                     : Icons.play_circle_filled,
//                               ),
//                               iconSize: 64,
//                               onPressed: () async {
//                                 if (!isPlaying) {
//                                   final source =
//                                       UrlSource(episode['audio_url']);
//                                   await player.play(source);
//                                 }
//                                 onPlayPause();
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.forward_30),
//                               iconSize: 32,
//                               onPressed: onSeekForward,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
//   }
// }

// class MiniPlayer extends StatelessWidget {
//   final Map<String, dynamic> episode;
//   final Map<String, dynamic> podcast; // Change to Map<String, dynamic>
//   final AudioPlayer player;
//   final bool isPlaying;
//   final VoidCallback onPlayPause;
//   final VoidCallback onSeekBackward;
//   final VoidCallback onSeekForward;

//   const MiniPlayer({
//     Key? key,
//     required this.episode,
//     required this.podcast, // Podcast as a Map
//     required this.player,
//     required this.isPlaying,
//     required this.onPlayPause,
//     required this.onSeekBackward,
//     required this.onSeekForward,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     String imageUrl =
//         episode['image'] ?? podcast['imageUrl'] ?? const Text('No image');

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FullScreenPlayer(
//               podcast: podcast,
//               episode: episode,
//               player: player,
//               isPlaying: isPlaying,
//               onPlayPause: onPlayPause,
//               onSeekBackward: onSeekBackward,
//               onSeekForward: onSeekForward,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         height: 64,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             imageUrl.isNotEmpty
//                 ? Image.network(
//                     imageUrl,
//                     width: 64,
//                     height: 64,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 64,
//                         height: 64,
//                         alignment: Alignment.center,
//                         child: const Text('No Image',
//                             style: TextStyle(color: Colors.grey)),
//                       );
//                     },
//                   )
//                 : Container(
//                     width: 64,
//                     height: 64,
//                     alignment: Alignment.center,
//                     child: const Text('No Image',
//                         style: TextStyle(color: Colors.grey)),
//                   ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       episode['name'],
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       episode['show'] ?? '',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.replay_10),
//               onPressed: onSeekBackward,
//             ),
//             IconButton(
//               icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//               onPressed: () {
//                 onPlayPause(); // Trigger play/pause
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.forward_30),
//               onPressed: onSeekForward,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
