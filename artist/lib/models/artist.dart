class Artist {
  final String id;
  final String userId;
  final String normalizedName;
  final String? bio;
  final String? imageUrl;
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String name;
  final String email;
  final int followerCount;

  Artist({
    required this.id,
    required this.userId,
    required this.normalizedName,
    this.bio,
    this.imageUrl,
    required this.isApproved,
    this.createdAt,
    this.updatedAt,
    required this.name,
    required this.email,
    this.followerCount = 0,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      userId: json['user_id'],
      normalizedName: json['normalized_name'],
      bio: json['bio'],
      imageUrl: json['image_url'],
      isApproved: json['is_approved'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      name: json['name'],
      email: json['email'],
      followerCount: json['follower_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'normalized_name': normalizedName,
      'bio': bio,
      'image_url': imageUrl,
      'is_approved': isApproved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name': name,
      'email': email,
      'follower_count': followerCount,
    };
  }

  Artist copyWith({
    String? id,
    String? userId,
    String? normalizedName,
    String? bio,
    String? imageUrl,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? email,
    int? followerCount,
  }) {
    return Artist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      normalizedName: normalizedName ?? this.normalizedName,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      email: email ?? this.email,
      followerCount: followerCount ?? this.followerCount,
    );
  }
}
