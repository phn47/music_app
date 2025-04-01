// lib/core/providers/theme_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true); // true = dark mode

  void toggleTheme() {
    state = !state;
  }
}
