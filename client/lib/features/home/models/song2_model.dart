class Song2Model {
  final String id;
  final String songName;
  final String thumbnailUrl;
  final String songUrl;
  final String hexCode;
  final String? album;
  final String genreId;

  Song2Model({
    required this.id,
    required this.songName,
    required this.thumbnailUrl,
    required this.songUrl,
    required this.hexCode,
    this.album,
    required this.genreId,
  });

  // Tạo instance từ JSON
  factory Song2Model.fromJson(Map<String, dynamic> json) {
    return Song2Model(
      id: json['id'] as String,
      songName: json['songName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      songUrl: json['songUrl'] as String,
      hexCode: json['hexCode'] as String,
      album: json['album'] as String?, // Có thể null
      genreId: json['genreId'] as String,
    );
  }

  // Chuyển instance sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'songName': songName,
      'thumbnailUrl': thumbnailUrl,
      'songUrl': songUrl,
      'hexCode': hexCode,
      'album': album,
      'genreId': genreId,
    };
  }
}
