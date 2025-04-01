// import 'dart:convert';
// import 'package:client/features/home/models/artist_model.dart';

// class SongModel {
//   final String id;
//   final String songName;
//   final List<ArtistModel> artists;
//   final String thumbnailUrl;
//   final String songUrl;
//   final String hexCode;
//   final String? album;
//   final String? genreId;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final String status;
//   final String? approvedBy;
//   final DateTime? approvedAt;
//   final String? rejectedReason;
//   final bool isHidden;
//   final String? hiddenReason;
//   final String? hiddenBy;
//   final DateTime? hiddenAt;

//   SongModel({
//     required this.id,
//     required this.songName,
//     required this.artists,
//     required this.thumbnailUrl,
//     required this.songUrl,
//     required this.hexCode,
//     this.album,
//     this.genreId,
//     this.createdAt,
//     this.updatedAt,
//     this.status = 'pending',
//     this.approvedBy,
//     this.approvedAt,
//     this.rejectedReason,
//     this.isHidden = false,
//     this.hiddenReason,
//     this.hiddenBy,
//     this.hiddenAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'song_name': songName,
//       'artists': artists.map((x) => x.toMap()).toList(),
//       'thumbnail_url': thumbnailUrl,
//       'song_url': songUrl,
//       'hex_code': hexCode,
//       'album': album,
//       'genre_id': genreId,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//       'status': status,
//       'approved_by': approvedBy,
//       'approved_at': approvedAt?.toIso8601String(),
//       'rejected_reason': rejectedReason,
//       'is_hidden': isHidden,
//       'hidden_reason': hiddenReason,
//       'hidden_by': hiddenBy,
//       'hidden_at': hiddenAt?.toIso8601String(),
//     };
//   }

//   factory SongModel.fromMap(Map<String, dynamic> map) {
//     return SongModel(
//       id: map['id'] ?? '',
//       songName: map['song_name'] ?? '',
//       artists: List<ArtistModel>.from(
//           map['artists']?.map((x) => ArtistModel.fromMap(x)) ?? []),
//       thumbnailUrl: map['thumbnail_url'] ?? '',
//       songUrl: map['song_url'] ?? '',
//       hexCode: map['hex_code'] ?? '',
//       album: map['album'],
//       genreId: map['genre_id'],
//       createdAt:
//           map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
//       updatedAt:
//           map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
//       status: map['status'] ?? 'pending',
//       approvedBy: map['approved_by'],
//       approvedAt: map['approved_at'] != null
//           ? DateTime.parse(map['approved_at'])
//           : null,
//       rejectedReason: map['rejected_reason'],
//       isHidden: map['is_hidden'] ?? false,
//       hiddenReason: map['hidden_reason'],
//       hiddenBy: map['hidden_by'],
//       hiddenAt:
//           map['hidden_at'] != null ? DateTime.parse(map['hidden_at']) : null,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory SongModel.fromJson(Map<String, dynamic> json) {
//     return SongModel(
//       id: json['id']?.toString() ?? '',
//       songName: json['song_name']?.toString() ?? '',
//       artists: (json['artists'] as List<dynamic>? ?? [])
//           .map((artist) => ArtistModel.fromJson(artist))
//           .toList(),
//       thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
//       songUrl: json['song_url']?.toString() ?? '',
//       hexCode: json['hex_code']?.toString() ?? '',
//       album: json['album']?.toString(),
//       genreId: json['genre_id']?.toString(),
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'])
//           : null,
//       status: json['status']?.toString() ?? 'pending',
//       approvedBy: json['approved_by']?.toString(),
//       approvedAt: json['approved_at'] != null
//           ? DateTime.parse(json['approved_at'])
//           : null,
//       rejectedReason: json['rejected_reason']?.toString(),
//       isHidden: json['is_hidden'] ?? false,
//       hiddenReason: json['hidden_reason']?.toString(),
//       hiddenBy: json['hidden_by']?.toString(),
//       hiddenAt:
//           json['hidden_at'] != null ? DateTime.parse(json['hidden_at']) : null,
//     );
//   }

//   SongModel copyWith({
//     String? id,
//     String? songName,
//     List<ArtistModel>? artists,
//     String? thumbnailUrl,
//     String? songUrl,
//     String? hexCode,
//     String? album,
//     String? genreId,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     String? status,
//     String? approvedBy,
//     DateTime? approvedAt,
//     String? rejectedReason,
//     bool? isHidden,
//     String? hiddenReason,
//     String? hiddenBy,
//     DateTime? hiddenAt,
//   }) {
//     return SongModel(
//       id: id ?? this.id,
//       songName: songName ?? this.songName,
//       artists: artists ?? this.artists,
//       thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
//       songUrl: songUrl ?? this.songUrl,
//       hexCode: hexCode ?? this.hexCode,
//       album: album ?? this.album,
//       genreId: genreId ?? this.genreId,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       status: status ?? this.status,
//       approvedBy: approvedBy ?? this.approvedBy,
//       approvedAt: approvedAt ?? this.approvedAt,
//       rejectedReason: rejectedReason ?? this.rejectedReason,
//       isHidden: isHidden ?? this.isHidden,
//       hiddenReason: hiddenReason ?? this.hiddenReason,
//       hiddenBy: hiddenBy ?? this.hiddenBy,
//       hiddenAt: hiddenAt ?? this.hiddenAt,
//     );
//   }
// }

import 'dart:convert';
import 'package:client/features/home/models/artist_model.dart';

class SongModel {
  final String id;
  final String songName;
  final List<ArtistModel> artists;
  final String thumbnailUrl;
  final String songUrl;
  final String hexCode;
  final String? album;
  final String? genreId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedReason;
  final bool isHidden;
  final String? hiddenReason;
  final String? hiddenBy;
  final DateTime? hiddenAt;
  final String? userName; // Thêm trường userName

  SongModel({
    required this.id,
    required this.songName,
    required this.artists,
    required this.thumbnailUrl,
    required this.songUrl,
    required this.hexCode,
    this.album,
    this.genreId,
    this.createdAt,
    this.updatedAt,
    this.status = 'pending',
    this.approvedBy,
    this.approvedAt,
    this.rejectedReason,
    this.isHidden = false,
    this.hiddenReason,
    this.hiddenBy,
    this.hiddenAt,
    this.userName, // Khởi tạo userName
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'song_name': songName,
      'artists': artists.map((x) => x.toMap()).toList(),
      'thumbnail_url': thumbnailUrl,
      'song_url': songUrl,
      'hex_code': hexCode,
      'album': album,
      'genre_id': genreId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejected_reason': rejectedReason,
      'is_hidden': isHidden,
      'hidden_reason': hiddenReason,
      'hidden_by': hiddenBy,
      'hidden_at': hiddenAt?.toIso8601String(),
      'userName': userName, // Thêm userName vào toMap
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? '',
      songName: map['song_name'] ?? '',
      artists: List<ArtistModel>.from(
          map['artists']?.map((x) => ArtistModel.fromMap(x)) ?? []),
      thumbnailUrl: map['thumbnail_url'] ?? '',
      songUrl: map['song_url'] ?? '',
      hexCode: map['hex_code'] ?? '',
      album: map['album'],
      genreId: map['genre_id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      status: map['status'] ?? 'pending',
      approvedBy: map['approved_by'],
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'])
          : null,
      rejectedReason: map['rejected_reason'],
      isHidden: map['is_hidden'] ?? false,
      hiddenReason: map['hidden_reason'],
      hiddenBy: map['hidden_by'],
      hiddenAt:
          map['hidden_at'] != null ? DateTime.parse(map['hidden_at']) : null,
      userName: map['userName'], // Lấy userName từ map
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id']?.toString() ?? '',
      songName: json['song_name']?.toString() ?? '',
      artists: (json['artists'] as List<dynamic>? ?? [])
          .map((artist) => ArtistModel.fromJson(artist))
          .toList(),
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      songUrl: json['song_url']?.toString() ?? '',
      hexCode: json['hex_code']?.toString() ?? '',
      album: json['album']?.toString(),
      genreId: json['genre_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      status: json['status']?.toString() ?? 'pending',
      approvedBy: json['approved_by']?.toString(),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      rejectedReason: json['rejected_reason']?.toString(),
      isHidden: json['is_hidden'] ?? false,
      hiddenReason: json['hidden_reason']?.toString(),
      hiddenBy: json['hidden_by']?.toString(),
      hiddenAt:
          json['hidden_at'] != null ? DateTime.parse(json['hidden_at']) : null,
      userName: json['userName']?.toString(), // Lấy userName từ JSON
    );
  }

  SongModel copyWith({
    String? id,
    String? songName,
    List<ArtistModel>? artists,
    String? thumbnailUrl,
    String? songUrl,
    String? hexCode,
    String? album,
    String? genreId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedReason,
    bool? isHidden,
    String? hiddenReason,
    String? hiddenBy,
    DateTime? hiddenAt,
    String? userName, // Thêm userName vào copyWith
  }) {
    return SongModel(
      id: id ?? this.id,
      songName: songName ?? this.songName,
      artists: artists ?? this.artists,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      songUrl: songUrl ?? this.songUrl,
      hexCode: hexCode ?? this.hexCode,
      album: album ?? this.album,
      genreId: genreId ?? this.genreId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      isHidden: isHidden ?? this.isHidden,
      hiddenReason: hiddenReason ?? this.hiddenReason,
      hiddenBy: hiddenBy ?? this.hiddenBy,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      userName: userName ?? this.userName,
    );
  }
}
