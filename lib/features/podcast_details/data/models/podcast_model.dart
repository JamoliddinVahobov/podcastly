class Podcast {
  final String id;
  final String name;
  final String publisher;
  final String? imageUrl;
  final String? description;

  Podcast({
    required this.id,
    required this.name,
    required this.publisher,
    this.imageUrl,
    this.description,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'],
      name: json['name'],
      publisher: json['publisher'],
      imageUrl:
          json['images']?.isNotEmpty ?? false ? json['images'][0]['url'] : null,
      description: json['description'] ?? '',
    );
  }
}
