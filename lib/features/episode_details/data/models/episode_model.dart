import '../../../../core/enums/image_size_enums.dart';
import '../../../../core/utils/image_handler.dart';
import '../../domain/entities/episode_entity.dart';

class EpisodeModel {
  final String id;
  final String name;
  final String? description;
  final int duration;
  final String? releaseDate;
  final String audioUrl;
  final ImageHandler imageHandler;

  EpisodeModel({
    required this.id,
    required this.name,
    this.description,
    required this.duration,
    this.releaseDate,
    required this.audioUrl,
    required this.imageHandler,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Episode',
      description: json['description'] as String?,
      duration: (json['duration_ms'] as num?)?.toInt() ?? 0,
      releaseDate: json['release_date'] as String?,
      audioUrl: json['audio_preview_url'] as String? ?? '',
      imageHandler: ImageHandler.fromJson(json['images'] as List<dynamic>?),
    );
  }

  Episode toEntity() {
    return Episode(
      id: id,
      name: name,
      description: description,
      duration: duration,
      releaseDate: releaseDate,
      audioUrl: audioUrl,
      smallImageUrl: imageHandler.smallImageUrl,
      mediumImageUrl: imageHandler.mediumImageUrl,
      largeImageUrl: imageHandler.largeImageUrl,
    );
  }

  String? getImageForSize(ImageSize size) {
    return imageHandler.getImageForSize(size);
  }
}
