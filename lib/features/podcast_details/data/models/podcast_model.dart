import 'package:podcast_app/core/mixins/image_size_mixin.dart';

class Podcast with ImageHandlingMixin {
  final String id;
  final String name;
  final String publisher;
  final String? description;
  @override
  final String? smallImageUrl; // 64x64
  @override
  final String? mediumImageUrl; // 300x300
  @override
  final String? largeImageUrl; // 640x640

  Podcast({
    required this.id,
    required this.name,
    required this.publisher,
    this.description,
    this.smallImageUrl,
    this.mediumImageUrl,
    this.largeImageUrl,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
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
    return Podcast(
      id: json['id'],
      name: json['name'],
      publisher: json['publisher'],
      description: json['description'] ?? '',
      smallImageUrl: smallImageUrl,
      mediumImageUrl: mediumImageUrl,
      largeImageUrl: largeImageUrl,
    );
  }
}
