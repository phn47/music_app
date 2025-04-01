// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

// Class để quản lý danh sách bài hát
class SongListNotifier extends StateNotifier<List<SongModel>> {
  SongListNotifier() : super([]);

  void addSong(SongModel song) {
    state = [...state, song];
  }

  // void removeSong(SongModels song) {
  //   state = state.where((s) => s.id != song.id).toList();
  // }
}

// Provider cho danh sách bài hát
final songListProvider =
    StateNotifierProvider<SongListNotifier, List<SongModel>>((ref) {
  return SongListNotifier();
});

// Hàm để gọi API và lấy danh sách bài hát
Future<List<SongModel>> fetchSongs() async {
  final response = await http.get(
    Uri.parse('${ServerConstant.serverURL}/song/list'),
    headers: {
      'Content-Type': 'application/json;charset=utf-8',

      'x-auth-token':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM5NmM2M2QyLTBhYjgtNGViOC05MWJkLWMyM2RlYWRhYTUzOCJ9.YguFpoWSPXoetL4RzQpckSJV6x5fRpoB5kLzCI58o0o', // Đảm bảo thay thế bằng token thật
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    String jsonString = utf8.decode(response.bodyBytes);
    List jsonResponse = json.decode(jsonString);
    // In danh sách bài hát
    if (jsonResponse.isNotEmpty) {
      return jsonResponse.map((song) => SongModel.fromMap(song)).toList();
    } else {
      throw Exception('No songs found in response');
    }
  } else {
    throw Exception('Failed to load songs');
  }
}

// Provider để quản lý danh sách bài hát
final songProvider = FutureProvider<List<SongModel>>((ref) async {
  final songs = await fetchSongs();
  ref.read(songListProvider.notifier).state =
      songs; // Thêm bài hát vào danh sách
  return songs;
});
