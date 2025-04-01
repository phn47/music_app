import 'dart:convert';
import 'dart:io';
import 'package:artist/core/constants/server_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/artist.dart';
import '../models/album.dart';

class ArtistService {
  final SharedPreferences prefs;
  final String baseUrl = '${ServerConstant.serverURL}/auth/artist';

  ArtistService({required this.prefs});

  Future<String?> getToken() async {
    final token = prefs.getString('token');
    print('Getting token from artist service: $token');
    return token;
  }

  Future<String?> getStoredArtistId() async {
    return prefs.getString('artist_id');
  }

  Future<Artist> getArtistProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      print('Using token for profile: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'x-auth-token': token,
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Artist.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thông tin nghệ sĩ');
      } else {
        throw Exception(
            'Failed to load artist profile: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting artist profile: $e");
      throw Exception('Error getting artist profile: $e');
    }
  }

  Future<void> updateProfile({
    String? normalizedName,
    String? bio,
    String? imageUrl,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          if (normalizedName != null) 'normalized_name': normalizedName,
          if (bio != null) 'bio': bio,
          if (imageUrl != null) 'image_url': imageUrl,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Lỗi khi cập nhật thông tin: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin: $e');
    }
  }

  Future<List<Album>> getMyAlbums() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/auth/artist/albums'),
        headers: {
          'x-auth-token': token,
        },
      );

      print('Albums response status: ${response.statusCode}');
      print('Albums response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        return jsonData.map((json) => Album.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi lấy danh sách album');
      }
    } catch (e) {
      print("Error getting albums: $e");
      throw Exception('Lỗi khi lấy danh sách album: $e');
    }
  }

  Future<Album> createAlbum(
      String name, String? description, bool isPublic, File thumbnail) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/albums/auth/artist/albums'),
      );

      request.headers['x-auth-token'] = token;

      request.fields['name'] = name;
      if (description != null) {
        request.fields['description'] = description;
      }
      request.fields['is_public'] = isPublic.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnail.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = utf8.decode(response.bodyBytes);
        return Album.fromJson(json.decode(responseBody));
      } else {
        throw Exception(
            'Lỗi khi tạo album: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print("Error creating album: $e");
      throw Exception('Lỗi khi tạo album: $e');
    }
  }
}
