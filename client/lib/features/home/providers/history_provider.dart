// lib/features/home/providers/history_provider.dart
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/models/song_model.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryNotifier extends StateNotifier<List<SongModel>> {
  final String userId;
  static const int _maxHistoryItems = 8;

  HistoryNotifier({required this.userId}) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songsJson = prefs.getStringList('recentSongs_$userId') ?? [];

      final songs = songsJson.map((s) {
        final Map<String, dynamic> songMap = jsonDecode(s);
        return SongModel.fromMap(songMap);
      }).toList();

      state = songs.take(_maxHistoryItems).toList();
    } catch (e) {
      print('Error loading history: $e');
      state = [];
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songsJson = state.map((s) => jsonEncode(s.toMap())).toList();
      await prefs.setStringList('recentSongs_$userId', songsJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  void addSong(SongModel song) async {
    if (state.any((s) => s.id == song.id)) return;

    await Future.delayed(Duration(milliseconds: 100));

    final songs = [song, ...state];
    if (songs.length > _maxHistoryItems) {
      songs.removeLast();
    }
    state = songs;
    _saveHistory();
  }

  void clearHistory() {
    state = [];
    _saveHistory();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<SongModel>>((ref) {
  final currentUser = ref.watch(currentUserNotifierProvider);
  final userId = currentUser?.id ?? '';
  return HistoryNotifier(userId: userId);
});
