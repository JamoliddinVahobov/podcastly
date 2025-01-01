import '../../../../core/enums/image_size_enums.dart';

class Episode {
  final String id;
  final String name;
  final String? description;
  final int duration;
  final String? releaseDate;
  final String audioUrl;
  final String? smallImageUrl;
  final String? mediumImageUrl;
  final String? largeImageUrl;

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

  String? getImageForSize(ImageSize size) {
    switch (size) {
      case ImageSize.small:
        return smallImageUrl;
      case ImageSize.medium:
        return mediumImageUrl;
      case ImageSize.large:
        return largeImageUrl;
    }
  }
}
