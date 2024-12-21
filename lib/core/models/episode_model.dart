class Episode {
  final String id;
  final String name;
  final String? description;
  final int duration;
  final String? releaseDate;
  final String audioUrl;
  final String? imageUrl;

  Episode({
    required this.id,
    required this.name,
    this.description,
    required this.duration,
    this.releaseDate,
    required this.audioUrl,
    this.imageUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    // Access the images list and get the 300px size image URL
    final images = json['images'] as List<dynamic>;
    final imageUrl = images.firstWhere(
      (image) => image['height'] == 300,
      orElse: () => null,
    )?['url']; // Get the image URL if available, otherwise return null

    return Episode(
      id: json['id'],
      name: json['name'] ?? 'Untitled Episode',
      description: json['description'] ?? '',
      duration: json['duration_ms'] ?? 0,
      releaseDate: json['release_date'],
      audioUrl: json['audio_preview_url'] ?? '',
      imageUrl: imageUrl,
    );
  }
}
