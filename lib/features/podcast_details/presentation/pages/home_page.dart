import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/core/dependency_injection/dependency_injection.dart';
import 'package:podcast_app/core/enums/image_size_enums.dart';
import 'package:podcast_app/features/podcast_details/domain/usecases/podcast_usecase.dart';
import '../../../auth/logic/auth_bloc.dart';
import '../../../auth/logic/auth_state.dart';
import '../../domain/entities/podcast_entity.dart';
import '../providers/podcast_provider_cubit/podcast_provider_cubit.dart';
import 'podcast_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final podcastUsecase = getIt<FetchPodcastsUsecase>();
    return BlocProvider(
      create: (context) => PodcastProviderCubit(
        fetchPodcastsUsecase: podcastUsecase,
      )..loadInitialPodcasts(),
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UnauthenticatedUser) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            }
          },
          child: BlocBuilder<PodcastProviderCubit, PodcastProviderState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<PodcastProviderCubit>().refreshPodcasts();
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
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
                      context.read<PodcastProviderCubit>().loadMorePodcasts();
                      return const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      );
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

  Widget _buildPodcastCard(BuildContext context, Podcast podcast) {
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
              child: podcast.getImageForSize(ImageSize.medium) != null
                  ? Image.network(
                      podcast.getImageForSize(ImageSize.medium)!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    )
                  : Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.podcasts, size: 40),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast.publisher,
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
