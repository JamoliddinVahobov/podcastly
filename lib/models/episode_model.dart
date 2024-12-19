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
    return Episode(
      id: json['id'],
      name: json['name'] ?? 'Untitled Episode',
      description: json['description'] ?? '',
      duration: json['duration_ms'] ?? 0,
      releaseDate: json['release_date'],
      audioUrl: json['audio_preview_url'] ?? '',
      imageUrl: json['episode_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration_ms': duration,
      'release_date': releaseDate,
      'audio_preview_url': audioUrl,
      if (imageUrl != null) 'episode_image': imageUrl,
    };
  }
}
