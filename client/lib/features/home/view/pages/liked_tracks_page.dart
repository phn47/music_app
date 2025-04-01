import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';

class LikedTracksPage extends ConsumerWidget {
  const LikedTracksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final likedSongs = ref.watch(getFavSongsProvider);
    final currentSong = ref.watch(currentSongNotifierProvider);

    return BaseScaffold(
      currentIndex: 3,
      appBar: AppBar(
        title: const Text('Bài hát ưa thích',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: Pallete.backgroundColor,
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                'Vui lòng đăng nhập để xem bài hát yêu thích',
                style: TextStyle(color: Colors.white),
              ),
            )
          : likedSongs.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có bài hát yêu thích nào',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return ListTile(
                            onTap: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .updateSong(song);
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(song.thumbnailUrl),
                              radius: 35,
                              backgroundColor: Pallete.backgroundColor,
                            ),
                            title: Text(
                              song.songName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              song.artists
                                  .map((artist) => artist.normalizedName)
                                  .join(', '),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: currentSong != null ? 66 + 16 : 16),
                  ],
                );
              },
              error: (error, st) {
                return Center(
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              loading: () => const Loader(),
            ),
    );
  }
}
