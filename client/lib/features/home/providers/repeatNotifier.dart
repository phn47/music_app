import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepeatNotifier extends StateNotifier<bool> {
  RepeatNotifier() : super(false) {
    _loadRepeatState();
  }

  Future<void> _loadRepeatState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isPressed') ?? false;
  }

  Future<void> toggleRepeat() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPressed', state);
  }
}

// Khai báo provider
final repeatNotifierProvider =
    StateNotifierProvider<RepeatNotifier, bool>((ref) {
  return RepeatNotifier();
});
