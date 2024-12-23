import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/episode_model.dart';
import '../models/podcast_model.dart';
import 'abstract_podcast_service.dart';
import 'token_management_service.dart';

class PodcastServiceImpl implements PocastService {
  final TokenManagementService _tokenService;

  PodcastServiceImpl(this._tokenService);

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
      debugPrint('access token: $accessToken');

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
      debugPrint('Error fetching podcasts: $e');
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
          'market': 'US', // Add market parameter
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('Episode API Response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'];
        return items.map((item) => Episode.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load episodes: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      debugPrint('Error fetching episodes: $e');
      rethrow;
    }
  }
}
