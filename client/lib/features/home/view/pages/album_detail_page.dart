import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/home/models/album_model.dart';
import 'package:client/features/home/view/pages/upload_album_song_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class AlbumDetailPage extends ConsumerStatefulWidget {
  final AlbumModel album;
  final String artname;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.artname,
  });

  @override
  ConsumerState<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends ConsumerState<AlbumDetailPage> {
  final _scrollController = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(getAlbumSongsProvider(widget.album.id));
    final currentUser = ref.watch(currentUserNotifierProvider);
    final isOwner = currentUser?.id == widget.album.user_id;

    return BaseScaffold(
      currentIndex: 3,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            _scrollController.value = scrollNotification.metrics.pixels;
          }
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                toolbarHeight: 56,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image(
                    image: NetworkImage(widget.album.thumbnail_url),
                    fit: BoxFit.cover,
                  ),
                ),
                expandedHeight: 300,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () => Navigator.pop(context),
                ),
                pinned: true,
                backgroundColor: Colors.transparent,
                title: ValueListenableBuilder<double>(
                  valueListenable: _scrollController,
                  builder: (context, scrollPosition, _) {
                    final showTitle = scrollPosition > 200;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: showTitle ? 1.0 : 0.0,
                      child: Text(widget.album.name),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.album.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                NetworkImage(widget.album.thumbnail_url),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                if (isOwner)
                                  IconButton(
                                    icon: Icon(
                                        Icons.add_circle_outline_outlined,
                                        color: Pallete.whiteColor
                                            .withOpacity(0.8)),
                                    onPressed: () {
                                      PageNavigation.navigateToChild(
                                        context,
                                        UploadAlbumSongPage(
                                            albumId: widget.album.id),
                                      );
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(Icons.more_horiz_outlined,
                                      color:
                                          Pallete.whiteColor.withOpacity(0.8)),
                                  onPressed: () => showOptionsBottomSheet(
                                      context, ref, isOwner),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 110),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                if (songs.value != null &&
                                    songs.value!.isNotEmpty) {
                                  final random = Random();
                                  final randomIndex =
                                      random.nextInt(songs.value!.length);
                                  ref
                                      .read(
                                          currentSongNotifierProvider.notifier)
                                      .updateSong(songs.value![randomIndex]);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/shuffle.png',
                                  color: Pallete.whiteColor,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Consumer(
                            builder: (context, ref, child) {
                              final currentSong =
                                  ref.watch(currentSongNotifierProvider);
                              final songNotifier = ref
                                  .read(currentSongNotifierProvider.notifier);
                              final isPlaying = currentSong != null &&
                                  songs.value != null &&
                                  songs.value!.any(
                                      (song) => song.id == currentSong.id) &&
                                  songNotifier.isPlaying;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () {
                                    if (songs.value != null &&
                                        songs.value!.isNotEmpty) {
                                      if (isPlaying) {
                                        // Pause logic - using songNotifier's playPause
                                        songNotifier.playPause();
                                      } else {
                                        if (currentSong != null &&
                                            songs.value!.any((song) =>
                                                song.id == currentSong.id)) {
                                          // If current song is from this album, just resume
                                          songNotifier.playPause();
                                        } else {
                                          // Play new song
                                          songNotifier
                                              .updateSong(songs.value![0]);
                                        }
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Pallete.gradient1,
                                    ),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              songs.when(
                data: (songsList) {
                  if (songsList.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Chưa có bài hát nào trong album',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songsList[index];
                          return ListTile(
                            leading: Image.network(
                              song.thumbnailUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  song.songName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        4), // Khoảng cách giữa songName và userName
                                Text(
                                  widget.artname ??
                                      'Unknown User', // Hiển thị userName hoặc giá trị mặc định
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              song.artists
                                  .map((artist) => artist.normalizedName)
                                  .join(', '),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.more_horiz_outlined,
                                        color: Pallete.whiteColor),
                                    onPressed: () {
                                      // Xử lý menu options
                                    },
                                  ),
                              ],
                            ),
                            onTap: () {
                              final updatedSong =
                                  song.copyWith(userName: widget.artname);
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .updateSong(updatedSong);
                            },
                          );
                        },
                        childCount: songsList.length,
                      ),
                    ),
                  );
                },
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Thêm hàm showOptionsBottomSheet
  void showOptionsBottomSheet(
      BuildContext context, WidgetRef ref, bool isOwner) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.cardColor,
      barrierColor: Colors.white.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ListTile(
              //   leading:
              //       const Icon(Icons.add_circle_outline, color: Colors.white),
              //   title: const Text(
              //     'Thêm vào Thư viện',
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     // Xử lý thêm vào thư viện
              //   },
              // ),
              // ListTile(
              //   leading:
              //       const Icon(Icons.ios_share_outlined, color: Colors.white),
              //   title: const Text(
              //     'Chia sẻ',
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     // Xử lý chia sẻ
              //   },
              // ),
              if (isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.white),
                  title: const Text(
                    'Chuyển sang riêng tư',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleTogglePrivacy(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Xóa album',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleDeleteAlbum(context, ref);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _handleDeleteAlbum(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text(
          'Xóa album',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa album này?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(homeViewModelProvider.notifier)
                  .deleteAlbum(widget.album.id);
              if (context.mounted) {
                Navigator.pop(context);
                showSnackBar(context, 'Đã xa album');
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _handleTogglePrivacy(BuildContext context, WidgetRef ref) async {
    await ref.read(homeViewModelProvider.notifier).toggleAlbumPrivacy(
          albumId: widget.album.id,
          isPublic: widget.album.is_public,
        );
    if (context.mounted) {
      showSnackBar(
        context,
        widget.album.is_public
            ? 'Đã chuyển sang riêng tư'
            : 'Đã chuyển sang công khai',
      );
    }
  }
}
