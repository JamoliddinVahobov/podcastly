import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/core/dependency_injection/dependency_injection.dart';
import '../../../../../core/helpers/helpers.dart';
import '../../models/episode_model.dart';
import 'remote_episode_source.dart';

class RemoteEpisodeSourceImpl implements RemoteEpisodeSource {
  final _dio = getIt<Dio>();

  @override
  Future<List<EpisodeModel>> fetchEpisodes(
    String showId, {
    required int offset,
    required int limit,
  }) async {
    try {
      String accessToken = await Helpers.getAccessToken();

      final response = await _dio.get(
        'https://api.spotify.com/v1/shows/$showId/episodes',
        queryParameters: {
          'market': 'US',
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
        final List<dynamic> items = response.data['items'] as List<dynamic>;

        // Filters out null items and maps valid ones to Episode objects
        return items
            .where((item) => item != null) // Remove null items
            .map((item) {
              try {
                return EpisodeModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing episode: $e');
                debugPrint('Problem episode data: $item');
                return null;
              }
            })
            .where((episode) => episode != null)
            .cast<EpisodeModel>()
            .toList();
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
