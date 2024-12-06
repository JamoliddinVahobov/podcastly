import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/logic/bloc/auth_bloc.dart';
import 'package:podcast_app/logic/bloc/auth_state.dart';
import 'package:podcast_app/presentation/auth%20pages/welcome_page.dart';
import '../../services/spotify_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allPodcasts = [];
  bool isLoading = false;
  bool hasMore = true;
  int offset = 0;
  final int limit = 21;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? currentlyPlayingEpisode;
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Map<String, dynamic>? selectedPodcast;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadMorePodcasts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    player.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        _loadMorePodcasts();
      }
    }
  }

  Future<void> _loadMorePodcasts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newPodcasts = await SpotifyService.fetchPodcasts(
        offset: offset,
        limit: limit,
      );

      setState(() {
        allPodcasts.addAll(newPodcasts);
        offset += limit;
        hasMore = newPodcasts.length == limit;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading more podcasts: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPodcasts() async {
    setState(() {
      offset = 0;
      hasMore = true;
      allPodcasts.clear();
    });
    await _loadMorePodcasts();
  }

  void _handleEpisodePlay(Map<String, dynamic> episode) {
    setState(() {
      currentlyPlayingEpisode = episode;
      isPlaying = true;
    });
  }

  void updateSelectedPodcast(Map<String, dynamic> podcast) {
    setState(() {
      selectedPodcast = podcast; // Update the selected podcast
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnauthenticatedUser) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshPodcasts,
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: currentlyPlayingEpisode != null ? 80 : 16,
                  ),
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: allPodcasts.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == allPodcasts.length) {
                      return Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const SizedBox(),
                      );
                    }
                    return _buildPodcastCard(allPodcasts[index]);
                  },
                ),
              ),
              if (currentlyPlayingEpisode != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MiniPlayer(
                    podcast: selectedPodcast ?? {},
                    episode: currentlyPlayingEpisode!,
                    player: player,
                    isPlaying: isPlaying,
                    onPlayPause: () {
                      setState(() {
                        isPlaying = !isPlaying;
                        isPlaying ? player.resume() : player.pause();
                      });
                    },
                    onSeekBackward: () async {
                      final position = await player.getCurrentPosition();
                      if (position != null) {
                        await player.seek(Duration(
                          seconds: (position.inSeconds - 10)
                              .clamp(0, double.infinity)
                              .toInt(),
                        ));
                      }
                    },
                    onSeekForward: () async {
                      final position = await player.getCurrentPosition();
                      if (position != null) {
                        await player.seek(Duration(
                          seconds: position.inSeconds + 30,
                        ));
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPodcastCard(Map<String, dynamic> podcast) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                podcast: podcast,
                player: player,
                onPlayEpisode: _handleEpisodePlay,
              ),
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

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> podcast;
  final AudioPlayer player;
  final Function(Map<String, dynamic>) onPlayEpisode;

  const DetailsPage({
    Key? key,
    required this.podcast,
    required this.player,
    required this.onPlayEpisode,
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<Map<String, dynamic>> episodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    try {
      final fetchedEpisodes =
          await SpotifyService.fetchEpisodes(widget.podcast['id']);
      setState(() {
        episodes = fetchedEpisodes;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching episodes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isPlaying = false; // Track the play state

  void onPlayPause(Map<String, dynamic> episode) async {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      final source = UrlSource(episode['audio_url']);
      await widget.player.play(source);
    } else {
      await widget.player.pause();
    }
  }

  void onSeekBackward() {
    widget.player
        .seek(const Duration(seconds: -10)); // Seek backward by 10 seconds
  }

  void onSeekForward() {
    widget.player
        .seek(const Duration(seconds: 10)); // Seek forward by 10 seconds
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.podcast['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.podcast['image'],
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
                    widget.podcast['name'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.podcast['publisher'],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.podcast['description'] ?? '',
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
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
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
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      onPressed: () async {
                        final source = UrlSource(episode['audio_url']);
                        await widget.player.play(source);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenPlayer(
                            podcast: widget.podcast,
                            episode: episode,
                            player: widget.player,
                            isPlaying:
                                isPlaying, // Pass the current playing state
                            onPlayPause: () => onPlayPause(
                                episode), // Pass the play/pause function
                            onSeekBackward:
                                onSeekBackward, // Pass the seek backward function
                            onSeekForward:
                                onSeekForward, // Pass the seek forward function
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenPlayer extends StatelessWidget {
  final Map<String, dynamic> episode;
  final AudioPlayer player;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final Map<String, dynamic> podcast;

  const FullScreenPlayer({
    super.key,
    required this.episode,
    required this.podcast,
    required this.player,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: episode['image'] != null &&
                                  episode['image']!.isNotEmpty
                              ? Image.network(
                                  episode['image']!,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                )
                              : podcast['image'] != null &&
                                      podcast['image']!.isNotEmpty
                                  ? Image.network(
                                      podcast['image']!,
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Text(
                                        'No image available for this podcast channel',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          episode['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          episode['show'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        StreamBuilder<Duration>(
                          stream:
                              player.onPositionChanged, // Use onPositionChanged
                          builder: (context, positionSnapshot) {
                            final position =
                                positionSnapshot.data ?? Duration.zero;
                            return FutureBuilder<Duration?>(
                              future: player.getDuration(), // Get duration here
                              builder: (context, durationSnapshot) {
                                // Check if duration is null and provide a default value
                                final duration =
                                    durationSnapshot.data ?? Duration.zero;

                                return Column(
                                  children: [
                                    Slider(
                                      value: position.inSeconds.toDouble(),
                                      max: duration.inSeconds.toDouble(),
                                      onChanged: (value) {
                                        player.seek(
                                            Duration(seconds: value.toInt()));
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(position),
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          Text(
                                            _formatDuration(duration),
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10),
                              iconSize: 32,
                              onPressed: onSeekBackward,
                            ),
                            IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              iconSize: 64,
                              onPressed: () async {
                                if (!isPlaying) {
                                  final source =
                                      UrlSource(episode['audio_url']);
                                  await player.play(source);
                                }
                                onPlayPause();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.forward_30),
                              iconSize: 32,
                              onPressed: onSeekForward,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}

class MiniPlayer extends StatelessWidget {
  final Map<String, dynamic> episode;
  final Map<String, dynamic> podcast; // Change to Map<String, dynamic>
  final AudioPlayer player;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;

  const MiniPlayer({
    Key? key,
    required this.episode,
    required this.podcast, // Podcast as a Map
    required this.player,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeekBackward,
    required this.onSeekForward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        episode['image'] ?? podcast['imageUrl'] ?? const Text('No image');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenPlayer(
              podcast: podcast,
              episode: episode,
              player: player,
              isPlaying: isPlaying,
              onPlayPause: onPlayPause,
              onSeekBackward: onSeekBackward,
              onSeekForward: onSeekForward,
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
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        child: const Text('No Image',
                            style: TextStyle(color: Colors.grey)),
                      );
                    },
                  )
                : Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    child: const Text('No Image',
                        style: TextStyle(color: Colors.grey)),
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      episode['show'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: onSeekBackward,
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                onPlayPause(); // Trigger play/pause
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_30),
              onPressed: onSeekForward,
            ),
          ],
        ),
      ),
    );
  }
}















// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import '../services/spotify_service.dart';

// class PodcastsPage extends StatefulWidget {
//   const PodcastsPage({Key? key}) : super(key: key);

//   @override
//   _PodcastsPageState createState() => _PodcastsPageState();
// }

// class _PodcastsPageState extends State<PodcastsPage> {
//   List<Map<String, dynamic>> allPodcasts = [];
//   bool isLoading = false;
//   bool hasMore = true;
//   int offset = 0;
//   final int limit = 21;
//   final ScrollController _scrollController = ScrollController();
//   Map<String, dynamic>? currentlyPlayingEpisode;
//   final AudioPlayer player = AudioPlayer();
//   bool isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//     _loadMorePodcasts();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     player.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       if (!isLoading && hasMore) {
//         _loadMorePodcasts();
//       }
//     }
//   }

//   Future<void> _loadMorePodcasts() async {
//     if (isLoading || !hasMore) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final newPodcasts = await SpotifyService.fetchPodcasts(
//         offset: offset,
//         limit: limit,
//       );

//       setState(() {
//         allPodcasts.addAll(newPodcasts);
//         offset += limit;
//         hasMore = newPodcasts.length == limit;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading more podcasts: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshPodcasts() async {
//     setState(() {
//       offset = 0;
//       hasMore = true;
//       allPodcasts.clear();
//     });
//     await _loadMorePodcasts();
//   }


//   void _handleEpisodePlay(Map<String, dynamic> episode) {
//     setState(() {
//       currentlyPlayingEpisode = episode;
//       isPlaying = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           'Podcasts',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Stack(
//         children: [
//           RefreshIndicator(
//             onRefresh: _refreshPodcasts,
//             child: GridView.builder(
//               padding: EdgeInsets.only(
//                 left: 16,
//                 right: 16,
//                 top: 16,
//                 bottom: currentlyPlayingEpisode != null ? 80 : 16,
//               ),
//               controller: _scrollController,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.75,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//               ),
//               itemCount: allPodcasts.length + (hasMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == allPodcasts.length) {
//                   return Center(
//                     child: isLoading
//                         ? const CircularProgressIndicator()
//                         : const SizedBox(),
//                   );
//                 }
//                 return _buildPodcastCard(allPodcasts[index]);
//               },
//             ),
//           ),
//           if (currentlyPlayingEpisode != null)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: MiniPlayer(
//                 episode: currentlyPlayingEpisode!,
//                 player: player,
//                 isPlaying: isPlaying,
//                 onPlayPause: () {
//                   setState(() {
//                     isPlaying = !isPlaying;
//                     isPlaying ? player.resume() : player.pause();
//                   });
//                 },
//                 onSeekBackward: () {
//                   player.seek(Duration(
//                     seconds: (player.position.value.inSeconds - 10).clamp(0, double.infinity).toInt(),
//                   ));
//                 },
//                 onSeekForward: () {
//                   player.seek(Duration(
//                     seconds: player.position.value.inSeconds + 30,
//                   ));
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//    Widget _buildPodcastCard(Map<String, dynamic> podcast) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DetailsPage(
//                 podcast: podcast,
//                 player: player,
//                 onPlayEpisode: _handleEpisodePlay,
//               ),
//             ),
//           );
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: Image.network(
//                 podcast['image'],
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 120,
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       podcast['name'],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       podcast['publisher'],
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }

// class DetailsPage extends StatefulWidget {
//   final Map<String, dynamic> podcast;

//   const DetailsPage({Key? key, required this.podcast}) : super(key: key);

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
//               fit: BoxFit.cover,
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
//                       icon: const Icon(Icons.play_circle_filled),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PlayPage(
//                               episode: episode,
//                               podcastImage: widget.podcast['image'],
//                               allEpisodes: episodes,
//                               currentIndex: index,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (context) => Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 episode['name'],
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(episode['description'] ?? ''),
//                             ],
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
// class MiniPlayer extends StatelessWidget {
//   final Map<String, dynamic> episode;
//   final AudioPlayer player;
//   final bool isPlaying;
//   final VoidCallback onPlayPause;
//   final VoidCallback onSeekBackward;
//   final VoidCallback onSeekForward;

//   const MiniPlayer({
//     Key? key,
//     required this.episode,
//     required this.player,
//     required this.isPlaying,
//     required this.onPlayPause,
//     required this.onSeekBackward,
//     required this.onSeekForward,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (context) => FullScreenPlayer(
//             episode: episode,
//             player: player,
//             isPlaying: isPlaying,
//             onPlayPause: onPlayPause,
//             onSeekBackward: onSeekBackward,
//             onSeekForward: onSeekForward,
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
//             Image.network(
//               episode['image'] ?? '',
//               width: 64,
//               height: 64,
//               fit: BoxFit.cover,
//             ),
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
//               onPressed: onPlayPause,
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

// class FullScreenPlayer extends StatelessWidget {
//   final Map<String, dynamic> episode;
//   final AudioPlayer player;
//   final bool isPlaying;
//   final VoidCallback onPlayPause;
//   final VoidCallback onSeekBackward;
//   final VoidCallback onSeekForward;

//   const FullScreenPlayer({
//     Key? key,
//     required this.episode,
//     required this.player,
//     required this.isPlaying,
//     required this.onPlayPause,
//     required this.onSeekBackward,
//     required this.onSeekForward,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: SingleChildScrollView(
//             controller: scrollController,
//             child: Column(
//               children: [
//                 const SizedBox(height: 8),
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(
//                           episode['image'] ?? '',
//                           width: double.infinity,
//                           height: 300,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         episode['name'],
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         episode['show'] ?? '',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       StreamBuilder<Duration>(
//                         stream: player.onPositionChanged,
//                         builder: (context, snapshot) {
//                           final position = snapshot.data ?? Duration.zero;
//                           return Column(
//                             children: [
//                               Slider(
//                                 value: position.inSeconds.toDouble(),
//                                 max: (player.duration?.inSeconds ?? 0).toDouble(),
//                                 onChanged: (value) {
//                                   player.seek(Duration(seconds: value.toInt()));
//                                 },
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       _formatDuration(position),
//                                       style: TextStyle(color: Colors.grey[600]),
//                                     ),
//                                     Text(
//                                       _formatDuration(player.duration ?? Duration.zero),
//                                       style: TextStyle(color: Colors.grey[600]),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.replay_10),
//                             iconSize: 32,
//                             onPressed: onSeekBackward,
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
//                             ),
//                             iconSize: 64,
//                             onPressed: onPlayPause,
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.forward_30),
//                             iconSize: 32,
//                             onPressed: onSeekForward,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
//   }
// }