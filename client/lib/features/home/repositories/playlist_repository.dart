import 'dart:convert';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/playlist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final playlistRepositoryProvider = Provider((ref) {
  return PlaylistRepository();
});

// Thêm provider để lắng nghe thay đổi từ SharedPreferences
final playlistsStreamProvider =
    StreamProvider<List<PlaylistModel>>((ref) async* {
  final repository = ref.watch(playlistRepositoryProvider);
  final userId = ref.watch(currentUserNotifierProvider)?.id;

  if (userId == null) {
    yield [];
    return;
  }

  // Lấy dữ liệu ban đầu
  final initialPlaylists = await repository.getPlaylists(userId);
  yield initialPlaylists;

  // Lắng nghe thay đổi
  yield* repository.watchPlaylists(userId);
});

class PlaylistRepository {
  static const String _playlistKey = 'user_playlists';

  // Stream để theo dõi thay đổi
  Stream<List<PlaylistModel>> watchPlaylists(String userId) async* {
    final prefs = await SharedPreferences.getInstance();

    while (true) {
      final String? playlistsJson = prefs.getString('${_playlistKey}_$userId');
      if (playlistsJson != null) {
        final List<dynamic> decoded = jsonDecode(playlistsJson);
        yield decoded.map((json) => PlaylistModel.fromJson(json)).toList();
      } else {
        yield [];
      }
      await Future.delayed(
          const Duration(milliseconds: 100)); // Polling interval
    }
  }

  Future<List<PlaylistModel>> getPlaylists(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? playlistsJson = prefs.getString('${_playlistKey}_$userId');

      if (playlistsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(playlistsJson);
      return decoded.map((json) => PlaylistModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePlaylists(
      String userId, List<PlaylistModel> playlists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        playlists.map((playlist) => playlist.toJson()).toList(),
      );
      await prefs.setString('${_playlistKey}_$userId', encoded);
    } catch (e) {
      rethrow;
    }
  }
}
