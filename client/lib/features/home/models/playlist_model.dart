import 'package:client/features/home/models/song_model.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String userId;
  final List<SongModel> songs;
  final DateTime createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.songs,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'songs': songs.map((song) => song.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String,
      songs: (json['songs'] as List)
          .map((songJson) =>
              SongModel.fromJson(songJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? userId,
    List<SongModel>? songs,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
