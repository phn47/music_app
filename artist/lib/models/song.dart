class Song {
  final String id;
  final String songName;
  final String songUrl;
  final String thumbnailUrl;
  final String hexCode;
  final String? artistId;
  final String? albumId;
  final int? playCount;

  Song({
    required this.id,
    required this.songName,
    required this.songUrl,
    required this.thumbnailUrl,
    required this.hexCode,
    this.artistId,
    this.albumId,
    this.playCount,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      songName: json['song_name'],
      songUrl: json['song_url'],
      thumbnailUrl: json['thumbnail_url'],
      hexCode: json['hex_code'],
      artistId: json['artist_id'],
      albumId: json['album_id'],
      playCount: json['play_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song_name': songName,
      'song_url': songUrl,
      'thumbnail_url': thumbnailUrl,
      'hex_code': hexCode,
      'artist_id': artistId,
      'album_id': albumId,
      'play_count': playCount,
    };
  }
}
