import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/token_management_service.dart';
import '../models/episode_model.dart';

class RemoteEpisodeSource {
  final TokenManagementService _tokenService;

  RemoteEpisodeSource(this._tokenService);

  Future<String> _getAccessToken() async {
    return await _tokenService.getAccessToken();
  }

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

        // Filter out null items and map valid ones to Episode objects
        return items
            .where((item) => item != null) // Remove null items
            .map((item) {
              try {
                return Episode.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing episode: $e');
                debugPrint('Problem episode data: $item');
                return null;
              }
            })
            .where((episode) => episode != null)
            .cast<Episode>()
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
