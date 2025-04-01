import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/server_constant.dart';

class AuthService {
  final SharedPreferences prefs;
  final String baseUrl = '${ServerConstant.serverURL}/auth/artist';

  AuthService({required this.prefs});

  Future<void> saveArtistId(String artistId) async {
    await prefs.setString('artist_id', artistId);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': await getToken() ?? '',
        },
        body: jsonEncode(
            {'email': email, 'password': password, 'role': 'artist'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user']['role'] != 'artist') {
          throw Exception('Tài khoản này không phải là nghệ sĩ');
        }
        await saveToken(data['token']);
        await saveArtistId(data['user']['artist_id']);
        return data;
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<Map<String, dynamic>> signup(
      String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'artist'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        await saveArtistId(data['user']['artist_id']);
        return data;
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<void> logout() async {
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = prefs.getString('token');
    return token != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString('token');
    print("Getting token from SharedPreferences: $token");
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    // Verify ngay sau khi lưu
    final savedToken = await prefs.getString('token');
    print("Token saved in SharedPreferences: $savedToken");
  }
}
