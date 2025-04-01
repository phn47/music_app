import 'dart:convert';

import 'package:client/features/home/models/song_model.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(HomeLocalRepositoryRef ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  final Box box = Hive.box();

  Future<void> uploadLocalSong(Map<String, dynamic> song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_song', jsonEncode(song));
    } catch (e) {
      print('Error saving song locally: $e');
    }
  }

  List<SongModel> loadSongs() {
    List<SongModel> songs = [];
    for (final key in box.keys) {
      songs.add(SongModel.fromJson(box.get(key)));
    }
    return songs;
  }

  // Phương thức để xóa tất cả các bài hát
  void clearAllSongs() {
    box.clear();
  }

  void clearBuffers() {
    try {
      box.clear();
    } catch (e) {
      print('Error clearing buffers: $e');
    }
  }

  Future<void> saveRecentSong(SongModel song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSongs = prefs.getStringList('recent_songs') ?? [];

      // Thêm ID bài hát mới vào đầu danh sách
      if (!recentSongs.contains(song.id)) {
        recentSongs.insert(0, song.id);
        // Giới hạn số lượng bài hát gần đây
        if (recentSongs.length > 20) {
          recentSongs.removeLast();
        }
        await prefs.setStringList('recent_songs', recentSongs);
      }
    } catch (e) {
      print('Error saving recent song: $e');
    }
  }
}
