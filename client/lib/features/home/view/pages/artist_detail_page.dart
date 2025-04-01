import 'package:client/core/providers/audio_player_provider.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/providers/dio_provider.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/providers/artist_provider.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/home/view/pages/album_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:just_audio/just_audio.dart';

class ArtistDetailPage extends ConsumerStatefulWidget {
  final String artistId;
  final String artistName;
  final String? imageUrl;

  const ArtistDetailPage({
    Key? key,
    required this.artistId,
    required this.artistName,
    this.imageUrl,
  }) : super(key: key);

  @override
  ConsumerState<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends ConsumerState<ArtistDetailPage> {
  bool isFollowing = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    try {
      final response = await ref.read(dioProvider).get(
            '/auth/artist/${widget.artistId}/is_following',
            options: Options(
              headers: {
                'x-auth-token': ref.read(currentUserNotifierProvider)?.token,
              },
            ),
          );
      setState(() {
        isFollowing = response.data['is_following'];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleFollow() async {
    try {
      await ref.read(dioProvider).post(
            '/auth/artist/${widget.artistId}/follow',
            options: Options(
              headers: {
                'x-auth-token': ref.read(currentUserNotifierProvider)?.token,
              },
            ),
          );
      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final artistSongs = ref.watch(artistSongsProvider(widget.artistId));
    final artistAlbums = ref.watch(artistAlbumsProvider(widget.artistId));
    final currentSong = ref.watch(currentSongNotifierProvider);

    return BaseScaffold(
      currentIndex: 2,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFollowing ? Icons.favorite : Icons.favorite_border,
                  color: isFollowing ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFollow,
              ),
            ],
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.artistName,
                style: const TextStyle(
                  color: Pallete.whiteColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Pallete.gradient2,
                      child: const Icon(Icons.person, size: 100),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artist info
                  // Row(
                  //   children: [
                  //     CircleAvatar(
                  //       radius: 40,
                  //       backgroundImage: NetworkImage(widget.imageUrl ?? ''),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             widget.artistName,
                  //             style: Theme.of(context).textTheme.headlineMedium,
                  //           ),
                  //           Text(
                  //             '${artistSongs.length} người nghe hàng tháng',
                  //             style: Theme.of(context).textTheme.bodyMedium,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Follow button bên trái
                      Container(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: Text(
                            isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Nhóm nút play và shuffle bên phải
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shuffle button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                if (artistSongs.value != null &&
                                    artistSongs.value!.isNotEmpty) {
                                  final random = Random();
                                  final randomIndex =
                                      random.nextInt(artistSongs.value!.length);
                                  ref
                                      .read(
                                          currentSongNotifierProvider.notifier)
                                      .updateSong(
                                          artistSongs.value![randomIndex]);
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
                          const SizedBox(width: 16),

                          // Play button
                          Consumer(
                            builder: (context, ref, child) {
                              final currentSong =
                                  ref.watch(currentSongNotifierProvider);
                              final songNotifier = ref
                                  .read(currentSongNotifierProvider.notifier);
                              final isPlaying = currentSong != null &&
                                  artistSongs.value != null &&
                                  artistSongs.value!.any(
                                      (song) => song.id == currentSong.id) &&
                                  songNotifier.isPlaying;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: () {
                                    if (artistSongs.value != null &&
                                        artistSongs.value!.isNotEmpty) {
                                      if (isPlaying) {
                                        // Pause logic - using songNotifier's playPause
                                        songNotifier.playPause();
                                      } else {
                                        if (currentSong != null &&
                                            artistSongs.value!.any((song) =>
                                                song.id == currentSong.id)) {
                                          // If current song is from this artist, just resume
                                          songNotifier.playPause();
                                        } else {
                                          // Play new song
                                          songNotifier.updateSong(
                                              artistSongs.value![0]);
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
                ],
              ),
            ),
          ),
          artistSongs.when(
            data: (songs) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bài hát',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.thumbnailUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            song.songName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            widget.artistName,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Consumer(
                            builder: (context, ref, child) {
                              final currentSong =
                                  ref.watch(currentSongNotifierProvider);
                              final isPlaying = currentSong?.id == song.id;

                              return isPlaying
                                  ? AudioWaveBar()
                                  : const SizedBox();
                            },
                          ),
                          onTap: () {
                            ref
                                .read(currentSongNotifierProvider.notifier)
                                .updateSong(song);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Loader()),
            error: (error, stack) => const SliverToBoxAdapter(
              child: Center(child: Text('Lỗi khi tải bài hát')),
            ),
          ),
          artistAlbums.when(
            data: (albums) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Album',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        return GestureDetector(
                          onTap: () {
                            PageNavigation.navigateToChild(
                              context,
                              AlbumDetailPage(
                                  album: album, artname: album.userName ?? ""),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(album.thumbnail_url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                album.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Loader()),
            error: (error, stack) => const SliverToBoxAdapter(
              child: Center(child: Text('Lỗi khi tải album')),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: currentSong != null ? 82 : 16),
          ),
        ],
      ),
    );
  }
}

class AudioWaveBar extends StatefulWidget {
  @override
  State<AudioWaveBar> createState() => _AudioWaveBarState();
}

class _AudioWaveBarState extends State<AudioWaveBar>
    with TickerProviderStateMixin {
  late List<AnimationController> controllers;
  final int barCount = 5;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600),
      ),
    );

    for (var i = 0; i < controllers.length; i++) {
      _startAnimation(i);
    }
  }

  void _startAnimation(int index) {
    int delay = ((barCount - 1 - index) * 50).abs();

    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;

      controllers[index].forward().then((_) {
        if (!mounted) return;
        controllers[index].reverse().then((_) {
          if (!mounted) return;
          _startAnimation(index);
        });
      });
    });
  }

  void _pauseAnimation() {
    for (var controller in controllers) {
      controller.stop();
    }
  }

  void _resumeAnimation() {
    for (var i = 0; i < controllers.length; i++) {
      _startAnimation(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final songNotifier = ref.watch(currentSongNotifierProvider.notifier);
        final isPlaying = songNotifier.isPlaying;

        // Pause or resume animation based on playback state
        if (isPlaying) {
          _resumeAnimation();
        } else {
          _pauseAnimation();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            barCount,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedBuilder(
                animation: controllers[index],
                builder: (context, child) {
                  double minHeight = 5.0;
                  double maxHeight = 20.0;
                  double height = minHeight +
                      (maxHeight - minHeight) * controllers[index].value;

                  return Container(
                    width: 2,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
