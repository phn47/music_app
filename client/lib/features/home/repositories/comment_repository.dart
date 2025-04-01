import 'package:client/features/home/models/comment_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/dio_provider.dart';

part 'comment_repository.g.dart';

@riverpod
CommentRepository commentRepository(CommentRepositoryRef ref) {
  return CommentRepository(ref.watch(dioProvider));
}

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  Future<List<CommentModel>> getComments(String songId) async {
    try {
      final response = await _dio.get('/songs/song/$songId/comments');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      if (response.data is Map && response.data['comments'] is List) {
        return (response.data['comments'] as List)
            .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Không thể tải bình luận: $e');
    }
  }

  Future<void> addComment(String songId, String content, String userId) async {
    try {
      await _dio.post('/songs/song/$songId/comment', data: {
        'content': content,
        'user_id': userId,
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      }
      throw Exception('Không thể thêm bình luận: $e');
    }
  }

  Future<void> editComment({
    required String songId,
    required String commentId,
    required String content,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/songs/song/$songId/chinhsuacmt/$commentId',
        data: {
          'content': content,
        },
        options: Options(
          headers: {
            'x-auth-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Bình luận đã được chỉnh sửa thành công");
      } else {
        throw Exception('Đã xảy ra lỗi khi chỉnh sửa bình luận.');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception(
              'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.');
        } else if (e.response?.statusCode == 404) {
          throw Exception(e.response?.data['detail'] ??
              'Không thể tìm thấy bình luận hoặc bài hát.');
        }
      }
      throw Exception('Không thể chỉnh sửa bình luận: $e');
    }
  }

  // void debugToken() async {
  //   final token = await getToken();
  //   print('Token hiện tại: $token');
  // }

  // Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Key 'authToken' là tên bạn dùng để lưu token vào SharedPreferences.
  //   return prefs.getString('authToken');
  // }

  // Future<void> saveToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('authToken', token);
  // }

  // Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Key 'authToken' là tên bạn dùng để lưu token vào SharedPreferences.
  //   return prefs.getString('token');
  // }

  Future<void> deleteComment({
    required String songId,
    required String commentId,
    required String token,
  }) async {
    try {
      // final token = await getToken();

      await _dio.post(
        '/songs/song/$songId/xoacmt/$commentId',
        options: Options(
          headers: {
            'x-auth-token': token,
          },
        ),
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      }
      throw Exception('Không thể xóa bình luận: $e');
    }
  }

  // Future<String> getToken() async {
  //   throw UnimplementedError('Cần implement phương thức getToken()');
  // }
}
