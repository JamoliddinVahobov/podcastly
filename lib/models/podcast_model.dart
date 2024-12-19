import 'episode_model.dart';

class Podcast {
  final String id;
  final String name;
  final String publisher;
  final String? imageUrl;
  final String? description;
  final List<Episode>? episodes;

  Podcast({
    required this.id,
    required this.name,
    required this.publisher,
    this.episodes,
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
      episodes: json['episodes'] != null
          ? (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'publisher': publisher,
      'imageUrl': imageUrl,
      'description': description,
      'episodes': episodes?.map((e) => e.toJson()).toList(),
    };
  }
}
