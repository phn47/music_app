import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/providers/genre_songs_provider.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:dio/dio.dart';

class GenreSongsPage extends ConsumerWidget {
  final String genreId;
  final String genreName;

  const GenreSongsPage(
      {required this.genreId, required this.genreName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      currentIndex: 1,
      appBar: AppBar(
        title: Text(genreName),
        backgroundColor: Colors.transparent,
      ),
      body: ref.watch(genreSongsProvider(genreId)).when(
            data: (songs) {
              if (songs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: Pallete.greyColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có bài hát nào thuộc thể loại này',
                        style: TextStyle(
                          color: Pallete.greyColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentSongNotifierProvider.notifier)
                          .updateSong5(song, songs);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(song.thumbnailUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.songName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  song.userName ??
                                      'Unknown Artist', // Hiển thị `userName` nếu có, ngược lại hiển thị "Unknown Artist"
                                  style: const TextStyle(
                                    color: Pallete.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) {
              if (error is DioException && error.response?.statusCode == 500) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: Pallete.greyColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có bài hát nào thuộc thể loại này',
                        style: TextStyle(
                          color: Pallete.greyColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: Text(
                  'Đã xảy ra lỗi: ${error.toString()}',
                  style: const TextStyle(color: Pallete.whiteColor),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
