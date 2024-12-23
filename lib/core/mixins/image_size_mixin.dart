import '../enums/image_size_enums.dart';

mixin ImageHandlingMixin {
  String? get smallImageUrl;
  String? get mediumImageUrl;
  String? get largeImageUrl;

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
