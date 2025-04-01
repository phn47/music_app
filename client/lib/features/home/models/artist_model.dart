import 'dart:convert';

class ArtistModel {
  final String id;
  final String userId;
  final String normalizedName;
  final String name;
  final String? bio; // bio có thể null
  final String? imageUrl; // imageUrl có thể null
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt; // updatedAt có thể null
  final DateTime? approvedAt;
  final String? approvedBy;

  ArtistModel({
    required this.id,
    required this.userId,
    required this.normalizedName,
    required this.name,
    this.bio, // Tham số có thể null
    this.imageUrl, // Tham số có thể null
    this.isApproved = false,
    this.createdAt,
    this.updatedAt, // Tham số có thể null
    this.approvedAt,
    this.approvedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'normalized_name': normalizedName,
      'name': name,
      'bio': bio, // có thể là null
      'image_url': imageUrl, // có thể là null
      'is_approved': isApproved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(), // có thể là null
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
    };
  }

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      normalizedName: map['normalized_name'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'], // giá trị null nếu không có
      imageUrl: map['image_url'], // giá trị null nếu không có
      isApproved: map['is_approved'] ?? false,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null, // giá trị null nếu không có
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'])
          : null,
      approvedBy: map['approved_by'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ArtistModel.fromJson(String source) =>
      ArtistModel.fromMap(json.decode(source));
}
