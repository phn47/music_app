class CommentModel {
  final String id;
  final String songId;
  final String userId;
  final String userName; // Thêm trường userName
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.songId,
    required this.userId,
    required this.userName, // Thêm userName vào constructor
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'songId': songId,
      'userId': userId,
      'userName': userName, // Thêm userName vào trong JSON
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      songId: json['song_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '', // Lấy user_name từ JSON
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, songId: $songId, userId: $userId, userName: $userName, content: $content, createdAt: $createdAt)';
  }
}
