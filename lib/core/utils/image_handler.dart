import '../enums/image_size_enums.dart';

class ImageHandler {
  final String? smallImageUrl;
  final String? mediumImageUrl;
  final String? largeImageUrl;

  ImageHandler({
    this.smallImageUrl,
    this.mediumImageUrl,
    this.largeImageUrl,
  });

  factory ImageHandler.fromJson(List<dynamic>? images) {
    if (images == null || images.isEmpty) {
      return ImageHandler();
    }

    String? getImage(int height) {
      return images.firstWhere(
        (image) => image['height'] == height,
        orElse: () => {'url': null},
      )['url'] as String?;
    }

    return ImageHandler(
      smallImageUrl: getImage(64),
      mediumImageUrl: getImage(300),
      largeImageUrl: getImage(640),
    );
  }

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
