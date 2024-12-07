import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/spotify_service.dart';
part 'podcast_details_event.dart';
part 'podcast_details_state.dart';

class PodcastDetailsBloc
    extends Bloc<PodcastDetailsEvent, PodcastDetailsState> {
  PodcastDetailsBloc() : super(const PodcastDetailsState()) {
    on<LoadPodcastDetails>(_onLoadPodcastDetails);
  }

  Future<void> _onLoadPodcastDetails(
      LoadPodcastDetails event, Emitter<PodcastDetailsState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final episodes = await SpotifyService.fetchEpisodes(event.podcastId);

      emit(PodcastDetailsState(
        podcast: state.podcast,
        episodes: episodes,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      print('Error loading podcast details: $e');
    }
  }
}
