import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:podcast_app/core/dependency_injection/dependency_injection.dart';
import '../../../../../core/helpers/helpers.dart';
import '../../models/podcast_model.dart';
import 'remote_podcast_source.dart';

class RemotePodcastSourceImpl implements RemotePodcastSource {
  final _dio = getIt<Dio>();

  @override
  Future<List<PodcastModel>> fetchPodcasts({
    required int offset,
    required int limit,
  }) async {
    try {
      String accessToken = await Helpers.getAccessToken();
      debugPrint('access token: $accessToken');

      final response = await _dio.get(
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
