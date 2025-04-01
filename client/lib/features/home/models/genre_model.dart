class GenreModel {
  final String id;
  final String name;
  final String? image_url;
  final String hex_code;
  final String? description;

  GenreModel({
    required this.id,
    required this.name,
    this.image_url,
    required this.hex_code,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': image_url,
      'hex_code': hex_code,
      'description': description,
    };
  }

  factory GenreModel.fromMap(Map<String, dynamic> map) {
    return GenreModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image_url: map['image_url'],
      hex_code: map['hex_code'] ?? '#000000',
      description: map['description'],
    );
  }

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'],
      name: json['name'],
      image_url: json['image_url'],
      hex_code: json['hex_code'] ?? '#000000',
      description: json['description'],
    );
  }
}
