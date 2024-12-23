import 'package:podcast_app/core/mixins/image_size_mixin.dart';

class Episode with ImageHandlingMixin {
  final String id;
  final String name;
  final String? description;
  final int duration;
  final String? releaseDate;
  final String audioUrl;
  @override
  final String? smallImageUrl; // 64x64
  @override
  final String? mediumImageUrl; // 300x300
  @override
  final String? largeImageUrl; // 640x640

  Episode({
    required this.id,
    required this.name,
    this.description,
    required this.duration,
    this.releaseDate,
    required this.audioUrl,
    this.smallImageUrl,
    this.mediumImageUrl,
    this.largeImageUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    String? smallImageUrl;
    String? mediumImageUrl;
    String? largeImageUrl;

    if (json['images'] != null &&
        json['images'] is List &&
        (json['images'] as List).isNotEmpty) {
      final images = json['images'] as List<dynamic>;

      // Find images for each size
      smallImageUrl = images.firstWhere(
        (image) => image['height'] == 64,
        orElse: () => {'url': null},
      )['url'] as String?;

      mediumImageUrl = images.firstWhere(
        (image) => image['height'] == 300,
        orElse: () => {'url': null},
      )['url'] as String?;

      largeImageUrl = images.firstWhere(
        (image) => image['height'] == 640,
        orElse: () => {'url': null},
      )['url'] as String?;
    }

    return Episode(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Episode',
      description: json['description'] as String?,
      duration: (json['duration_ms'] as num?)?.toInt() ?? 0,
      releaseDate: json['release_date'] as String?,
      audioUrl: json['audio_preview_url'] as String? ?? '',
      smallImageUrl: smallImageUrl,
      mediumImageUrl: mediumImageUrl,
      largeImageUrl: largeImageUrl,
    );
  }

  @override
  String toString() {
    return 'Episode(id: $id, name: $name, description: $description, duration: $duration, releaseDate: $releaseDate, audioUrl: $audioUrl, smallImageUrl: $smallImageUrl, mediumImageUrl: $mediumImageUrl, largeImageUrl: $largeImageUrl)';
  }
}
