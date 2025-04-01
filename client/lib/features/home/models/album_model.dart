class AlbumModel {
  final String id;
  final String name;
  final String? description;
  final String thumbnail_url;
  final bool is_public;
  final String user_id;
  final String? userName; // Thêm trường userName

  AlbumModel({
    required this.id,
    required this.name,
    this.description,
    required this.thumbnail_url,
    required this.is_public,
    required this.user_id,
    this.userName, // Khởi tạo userName
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnail_url': thumbnail_url,
      'is_public': is_public,
      'user_id': user_id,
      'userName': userName, // Thêm userName vào toMap
    };
  }

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      thumbnail_url: map['thumbnail_url'] ?? '',
      is_public: map['is_public'] ?? true,
      user_id: map['user_id'] ?? '',
      userName: map['userName'] ?? '', // Lấy userName từ map
    );
  }
}
