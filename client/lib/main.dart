import 'package:client/core/providers/audio_player_provider.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/providers/theme_provider.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/widgets/loading.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/view/pages/artists_page.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';

import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo audio background service
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.client.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      // Thêm các tùy chọn khác nếu cần
    );
  } catch (e) {
    print('Lỗi khởi tạo audio background: $e');
  }

  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

  // Tạo ProviderContainer và giữ nó không đổi
  final container = ProviderContainer(
    overrides: [
      // Thêm override để giữ instance của AudioPlayer
      audioPlayerProvider.overrideWithValue(AudioPlayer()),
    ],
  );

  try {
    await container
        .read(authViewModelProvider.notifier)
        .initSharedPreferences();
    await container.read(authViewModelProvider.notifier).getData();

    // Không invalidate provider khi không cần thiết
    //container.invalidate(getUserSongsProvider);
  } catch (e) {
    print('Lỗi khi lấy dữ liệu người dùng: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final isDarkMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Music App',
      theme: isDarkMode ? AppTheme.darkThemeMode : AppTheme.lightThemeMode,
      debugShowCheckedModeBanner: false,
      home: currentUser == null ? const LoginPage() : const HomePage(),
    );
  }
}
