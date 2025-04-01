import 'package:client/features/home/models/song2_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/core/providers/dio_provider.dart';

final genreSongsProvider =
    FutureProvider.family<List<SongModel>, String>((ref, genreId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/genre/$genreId/songs');

  if (response.statusCode == 200) {
    final List<dynamic> songsJson = response.data;
    return songsJson.map((json) {
      if (json is Map<String, dynamic>) {
        return SongModel.fromMap(json);
      }
      throw Exception('Dữ liệu không đúng định dạng');
    }).toList();
  }
  throw Exception('Không thể tải danh sách bài hát');
});
