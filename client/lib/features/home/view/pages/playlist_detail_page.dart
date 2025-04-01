import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/models/artist_model.dart';
import 'package:client/features/home/models/playlist_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/providers/playlist_provider.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/providers/current_song_notifier.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final PlaylistModel playlist;

  const PlaylistDetailPage({
    super.key,
    required this.playlist,
  });

  String _getArtistsNames(List<ArtistModel> artists) {
    return artists
        .map((artist) =>
            artist.name.isNotEmpty ? artist.name : artist.normalizedName)
        .join(', ');
  }

  void _playSong(WidgetRef ref, SongModel song, List<SongModel> playlistSongs) {
    final currentSongNotifier = ref.read(currentSongNotifierProvider.notifier);
    currentSongNotifier.updateSong5(song, playlistSongs);
  }

  void _showEditPlaylistBottomSheet(
      BuildContext context, WidgetRef ref, PlaylistModel playlist) {
    final TextEditingController nameController =
        TextEditingController(text: playlist.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.backgroundColor,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chỉnh sửa danh sách',
                    style: TextStyle(
                      color: Pallete.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Pallete.whiteColor),
                    decoration: const InputDecoration(
                      hintText: 'Tên danh sách phát',
                      hintStyle: TextStyle(color: Pallete.greyColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Pallete.greyColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Pallete.gradient2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            // Xóa playlist
                            await ref
                                .read(playlistsProvider.notifier)
                                .deletePlaylist(playlist.id);
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Đóng bottom sheet
                              Navigator.of(context)
                                  .pop(); // Quay lại trang trước
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Đã xóa danh sách phát')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Xóa danh sách phát',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isNotEmpty) {
                            try {
                              // Cập nhật tên playlist
                              await ref
                                  .read(playlistsProvider.notifier)
                                  .updatePlaylistName(
                                    playlist.id,
                                    nameController.text.trim(),
                                  );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã cập nhật danh sách'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e')),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallete.gradient2,
                        ),
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      currentIndex: 0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Pallete.whiteColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showEditPlaylistBottomSheet(context, ref, playlist),
            icon: const Icon(
              Icons.edit,
              color: Pallete.whiteColor,
            ),
          ),
        ],
      ),
      body: ref.watch(playlistsProvider).when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Có lỗi xảy ra: $error',
                style: const TextStyle(color: Pallete.whiteColor),
              ),
            ),
            data: (playlists) {
              final currentPlaylist = playlists.firstWhere(
                (p) => p.id == playlist.id,
                orElse: () => playlist,
              );

              if (currentPlaylist.songs.isEmpty) {
                return const Center(
                  child: Text(
                    'Chưa có bài hát nào trong danh sách',
                    style: TextStyle(
                      color: Pallete.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: currentPlaylist.songs.length,
                itemBuilder: (context, index) {
                  final song = currentPlaylist.songs[index];
                  return Dismissible(
                    key: Key(song.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(
                        Icons.delete,
                        color: Pallete.whiteColor,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      try {
                        await ref
                            .read(playlistsProvider.notifier)
                            .removeSongFromPlaylist(
                              currentPlaylist.id,
                              song.id,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa bài hát khỏi danh sách'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Pallete.greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            song.thumbnailUrl ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Pallete.greyColor,
                                child: const Icon(
                                  Icons.music_note,
                                  color: Pallete.whiteColor,
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          song.songName,
                          style: const TextStyle(
                            color: Pallete.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _getArtistsNames(song.artists),
                          style: TextStyle(
                            color: Pallete.whiteColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Pallete.whiteColor,
                          ),
                          onPressed: () {
                            // TODO: Hiển thị menu tùy chọn cho bài hát
                          },
                        ),
                        onTap: () {
                          _playSong(ref, song, currentPlaylist.songs);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
