import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/podcast_model.dart';
import '../../../../core/services/token_management_service.dart';

class RemotePodcastSource {
  final TokenManagementService _tokenService;

  RemotePodcastSource(this._tokenService);

  Future<String> _getAccessToken() async {
    return await _tokenService.getAccessToken();
  }

  Future<List<PodcastModel>> fetchPodcasts({
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
        return items.map((item) => PodcastModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load podcasts: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error fetching podcasts: $e');
      return [];
    }
  }
}
