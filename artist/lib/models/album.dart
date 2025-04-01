class Album {
  final String id;
  final String name;
  final String? description;
  final String thumbnailUrl;
  final bool isPublic;
  final String userId;

  Album({
    required this.id,
    required this.name,
    this.description,
    required this.thumbnailUrl,
    required this.isPublic,
    required this.userId,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      isPublic: json['is_public'],
      userId: json['user_id'],
    );
  }
}
