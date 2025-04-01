// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:client/features/home/models/fav_song_model.dart';

class UserModel {
  final String name;
  final String email;
  final String id;
  final String token;
  final List<FavSongModel> favorites;
  final String imageUrl;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.token,
    required this.favorites,
    required this.imageUrl,
    required this.role,
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? id,
    String? token,
    List<FavSongModel>? favorites,
    String? imageUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token,
      favorites: favorites ?? this.favorites,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'id': id,
      'token': token,
      'favorites': favorites.map((x) => x.toMap()).toList(),
      'imageUrl': imageUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      token: map['token'] ?? '',
      favorites: List<FavSongModel>.from(
        (map['favorites'] ?? []).map(
          (x) => FavSongModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      imageUrl: map['imageUrl'] ?? '',
      role: map['role'] ?? 'user',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, id: $id, token: $token, favorites: $favorites, imageUrl: $imageUrl, role: $role, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.id == id &&
        other.token == token &&
        listEquals(other.favorites, favorites) &&
        other.imageUrl == imageUrl &&
        other.role == role &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        id.hashCode ^
        token.hashCode ^
        favorites.hashCode ^
        imageUrl.hashCode ^
        role.hashCode ^
        createdAt.hashCode;
  }
}
