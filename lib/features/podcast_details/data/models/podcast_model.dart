import '../../../../core/enums/image_size_enums.dart';
import '../../../../core/utils/image_handler.dart';
import '../../domain/entities/podcast_entity.dart';

class PodcastModel {
  final String id;
  final String name;
  final String publisher;
  final String? description;
  final ImageHandler imageHandler;

  PodcastModel({
    required this.id,
    required this.name,
    required this.publisher,
    this.description,
    required this.imageHandler,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    return PodcastModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Podcast',
      publisher: json['publisher'] as String? ?? '',
      description: json['description'] as String?,
      imageHandler: ImageHandler.fromJson(json['images'] as List<dynamic>?),
    );
  }

  Podcast toEntity() {
    return Podcast(
      id: id,
      name: name,
      publisher: publisher,
      description: description,
      smallImageUrl: imageHandler.smallImageUrl,
      mediumImageUrl: imageHandler.mediumImageUrl,
      largeImageUrl: imageHandler.largeImageUrl,
    );
  }

  String? getImageForSize(ImageSize size) {
    return imageHandler.getImageForSize(size);
  }
}
