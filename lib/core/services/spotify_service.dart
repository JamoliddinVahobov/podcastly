import 'package:dio/dio.dart';
import 'package:podcast_app/core/services/token_management_service.dart';
import '../models/episode_model.dart';
import '../models/podcast_model.dart';
import 'abstract_podcast_service.dart';

class SpotifyService implements ApiService {
  final TokenManagementService _tokenService;

  SpotifyService(this._tokenService);

  Future<String> _getAccessToken() async {
    return await _tokenService.getAccessToken();
  }

  @override
  Future<List<Podcast>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    try {
      String accessToken = await _getAccessToken();

      final response = await Dio().get(
        'https://api.spotify.com/v1/search',
        queryParameters: {
          'q': 'podcast',
          'type': 'show',
          'market': 'US',
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['shows']['items'];
        return items.map((item) => Podcast.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load podcasts: ${response.data}');
      }
    } catch (e) {
      print('Error fetching podcasts: $e');
      return [];
    }
  }

  @override
  Future<List<Episode>> fetchEpisodes(
    String showId, {
    required int offset,
    required int limit,
  }) async {
    try {
      String accessToken = await _getAccessToken();

      final response = await Dio().get(
        'https://api.spotify.com/v1/shows/$showId/episodes',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      print('show id $showId');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'];

        return items.map((item) {
          if (item is Map<String, dynamic>) {
            return Episode.fromJson(item);
          } else {
            throw const FormatException('Invalid episode format');
          }
        }).toList();
      } else {
        throw Exception('Failed to load episodes: ${response.data}');
      }
    } catch (e) {
      print('Error fetching episodes: $e');
      return [];
    }
  }
}
