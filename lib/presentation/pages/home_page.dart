import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/presentation/auth%20pages/welcome_page.dart';
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
              return RefreshIndicator(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount:
                      state.podcasts.length + (state.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index >= state.podcasts.length) {
                      context.read<PodcastListBloc>().add(LoadMorePodcasts());
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildPodcastCard(context, state.podcasts[index]);
                  },
                ),
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
              builder: (context) => PodcastDetailsPage(podcast: podcast),
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
