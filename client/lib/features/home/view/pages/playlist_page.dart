import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:client/features/home/models/playlist_model.dart';
import 'package:client/features/home/providers/playlist_provider.dart';
import 'package:client/features/home/view/pages/playlist_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaylistPage extends ConsumerWidget {
  const PlaylistPage({super.key});

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.backgroundColor,
        title: const Text(
          'Thêm danh sách phát mới',
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Pallete.whiteColor),
          decoration: const InputDecoration(
            hintText: 'Đặt tên cho danh sách phát của bạn',
            hintStyle: TextStyle(color: Pallete.greyColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Pallete.greyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Pallete.gradient2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Pallete.greyColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                try {
                  await ref
                      .read(playlistsProvider.notifier)
                      .createPlaylist(textController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã tạo playlist mới'),
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
              }
            },
            child: const Text(
              'Tạo',
              style: TextStyle(color: Pallete.gradient2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      currentIndex: 2,
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
        title: const Text(
          'Danh sách phát',
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              if (playlists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.queue_music,
                        color: Pallete.whiteColor,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có danh sách phát nào',
                        style: TextStyle(
                          color: Pallete.whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tạo danh sách phát đầu tiên của bạn để\nlưu trữ và tổ chức bài hát yêu thích',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Pallete.greyColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showCreatePlaylistDialog(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallete.gradient2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline_outlined,
                          color: Pallete.whiteColor,
                        ),
                        label: const Text(
                          'Danh sách phát mới',
                          style: TextStyle(
                            color: Pallete.whiteColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistDetailPage(
                            playlist: playlist,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Pallete.greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                image: playlist.songs.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          playlist.songs.first.thumbnailUrl ??
                                              '',
                                        ),
                                        fit: BoxFit.cover,
                                        onError: (error, stackTrace) {
                                          // Fallback khi lỗi load ảnh
                                        },
                                      )
                                    : null,
                              ),
                              child: playlist.songs.isEmpty
                                  ? const Center(
                                      child: Icon(
                                        Icons.music_note,
                                        color: Pallete.whiteColor,
                                        size: 40,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.name,
                                  style: const TextStyle(
                                    color: Pallete.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${playlist.songs.length} bài hát',
                                  style: TextStyle(
                                    color: Pallete.whiteColor.withOpacity(0.7),
                                    fontSize: 14,
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
          ),
    );
  }
}
