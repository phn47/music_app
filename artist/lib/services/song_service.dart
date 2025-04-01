import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/song.dart';
import '../core/constants/server_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = '${ServerConstant.serverURL}/auth/artist';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Getting token from prefs for songs: $token');
    return token;
  }

  Future<void> uploadSong({
    required File song,
    required File thumbnail,
    required String songName,
    required String hexCode,
    required List<String> genreIds,
    List<String>? featuringArtistIds,
  }) async {
    try {
      final token = await getToken();
      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'x-auth-token': token ?? '',
      });

      // Add file fields
      request.files.add(await http.MultipartFile.fromPath('song', song.path));
      request.files
          .add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));

      // Add text fields
      request.fields['songName'] = songName;
      request.fields['hexCode'] = hexCode;
      request.fields['genreIds'] = json.encode(genreIds);

      // Debug log trước khi gửi
      print('Featuring artist IDs before sending: $featuringArtistIds');

      // Ensure featuring artists are properly encoded
      if (featuringArtistIds != null && featuringArtistIds.isNotEmpty) {
        request.fields['featuringArtistIds'] = json.encode(featuringArtistIds);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception(
            'Lỗi khi tải lên: ${json.decode(responseBody)['detail']}');
      }

      // Debug log response
      print('Upload response: $responseBody');
    } catch (e) {
      print('Upload service error: $e');
      rethrow;
    }
  }

  Future<void> deleteSong(String songId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$songId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa bài hát');
    }
  }

  Future<void> updateSong({
    required String songId,
    String? songName,
    String? hexCode,
    File? thumbnail,
  }) async {
    final token = await getToken();
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/$songId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    if (songName != null) request.fields['song_name'] = songName;
    if (hexCode != null) request.fields['hex_code'] = hexCode;
    if (thumbnail != null) {
      request.files
          .add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Không thể cập nhật bài hát');
    }
  }

  Future<List<Song>> getMySongs() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      print('Using token for my-songs: $token');

      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/auth/artist/my-songs'),
        headers: {
          'x-auth-token': token,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Bạn chưa được đăng ký là nghệ sĩ');
      } else {
        throw Exception('Không thể tải danh sách bài hát');
      }
    } catch (e) {
      print("Error getting my songs: $e");
      throw Exception('Lỗi khi tải danh sách bài hát');
    }
  }

  // Future<void> uploadSongToAlbum({
  //   required File song,
  //   required File thumbnail,
  //   required String songName,
  //   required String hexCode,
  //   required List<String> artistNames,
  //   required List<String> genreIds,
  //   required String albumId,
  //   List<File>? artistImages,
  // }) async {
  //   final token = await getToken();
  //   var request = http.MultipartRequest(
  //       'POST', Uri.parse('$baseUrl/albums/$albumId/songs'));

  //   if (token == null) {
  //     throw Exception('Không tìm thấy token xác thực');
  //   }

  //   request.headers['x-auth-token'] = token;

  //   // Add song file
  //   request.files.add(
  //     await http.MultipartFile.fromPath('song', song.path),
  //   );

  //   // Add thumbnail file
  //   request.files.add(
  //     await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
  //   );

  //   // Add other fields
  //   request.fields['song_name'] = songName;
  //   request.fields['hex_code'] = hexCode;
  //   request.fields['artist_names'] = jsonEncode(artistNames);
  //   request.fields['genre_ids'] = jsonEncode(genreIds);
  //   request.fields['album_id'] = albumId;

  //   // Add artist images if provided
  //   if (artistImages != null) {
  //     for (var i = 0; i < artistImages.length; i++) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'artist_images',
  //           artistImages[i].path,
  //         ),
  //       );
  //     }
  //   }

  //   try {
  //     final response = await request.send();
  //     if (response.statusCode != 200 && response.statusCode != 201) {
  //       throw Exception('Lỗi khi tải lên bài hát');
  //     }
  //   } catch (e) {
  //     print("Error uploading song: $e");
  //     throw Exception('Lỗi khi tải lên bài hát: $e');
  //   }
  // }

  Future<void> uploadSongToAlbum({
    required File song,
    required File thumbnail,
    required String songName,
    required String hexCode,
    // required List<String> artistNames,
    required List<String> genreIds,
    required String albumId,
    List<String>? featuringArtistIds,
  }) async {
    final token = await getToken();
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/albums/$albumId/songs'));

    if (token == null) {
      throw Exception('Không tìm thấy token xác thực');
    }

    request.headers['x-auth-token'] = token;

    // Add song and thumbnail files
    request.files.add(await http.MultipartFile.fromPath('song', song.path));
    request.files
        .add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));

    // Add other fields
    request.fields['song_name'] = songName;
    request.fields['hex_code'] = hexCode;
    request.fields['genreIds'] = jsonEncode(genreIds);
    // request.fields['featuringArtistIds'] = jsonEncode(artistNames);

    if (featuringArtistIds != null && featuringArtistIds.isNotEmpty) {
      request.fields['featuringArtistIds'] = json.encode(featuringArtistIds);
    }

    try {
      final response = await request.send();
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Lỗi khi tải lên bài hát');
      }
    } catch (e) {
      print("Error uploading song: $e");
      throw Exception('Lỗi khi tải lên bài hát: $e');
    }
  }

  Future<List<Song>> getAlbumSongs(String albumId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final response = await http.get(
        Uri.parse(
            '${ServerConstant.serverURL}/auth/artist/albums/$albumId/songs'),
        headers: {
          'x-auth-token': token,
        },
      );

      print('Get album songs response status: ${response.statusCode}');
      print('Get album songs response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception(
            'Không thể tải danh sách bài hát: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting album songs: $e");
      throw Exception('Lỗi khi tải danh sách bài hát: $e');
    }
  }

  Future<List<dynamic>> getGenres() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/genre/list'),
        headers: {
          'x-auth-token': token,
        },
      );

      print('Get genres response status: ${response.statusCode}');
      print('Get genres response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((genre) => {
                  'id': genre['id'],
                  'name': genre['name'],
                  'description': genre['description']
                })
            .toList();
      } else {
        throw Exception(
            'Không thể tải danh sách thể loại: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting genres: $e");
      throw Exception('Lỗi khi tải danh sách thể loại: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchArtists(
      {bool excludeCurrentArtist = false}) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/listartists'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // Chuyển đổi dữ liệu thành List<Map<String, dynamic>>
        final List<Map<String, dynamic>> artists = data
            .map((item) =>
                Map<String, dynamic>.from(item as Map<String, dynamic>))
            .toList();

        if (excludeCurrentArtist) {
          final prefs = await SharedPreferences.getInstance();
          final String? currentArtistId = prefs.getString('artist_id');

          return artists
              .where((artist) => artist['id'] != currentArtistId)
              .toList();
        }

        return artists;
      } else {
        throw Exception(
            'Không thể tải danh sách nghệ sĩ: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching artists: $e");
      throw Exception('Lỗi khi tải danh sách nghệ sĩ: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableArtists() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/listartists'),
        headers: {
          'x-auth-token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Không thể lấy danh sách nghệ sĩ');
      }
    } catch (e) {
      print("Error getting available artists: $e");
      rethrow;
    }
  }
}
