import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/features/home/providers/artist_provider.dart';
import 'package:client/features/home/providers/genre_provider.dart';
import 'package:client/features/home/providers/song_list_provider.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/home/view/pages/album_detail_page.dart';
import 'package:client/features/home/view/widgets/wave_dots_animation.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/providers/history_provider.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/models/album_model.dart';
import 'package:client/features/home/view/pages/artist_detail_page.dart';
import 'package:client/features/home/view/pages/genre_songs_page.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  ConsumerState<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.97);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentlyPlayedSongs =
        ref.watch(homeViewModelProvider.notifier).getRecentlyPlayedSongs();
    print("Recently played songs: $recentlyPlayedSongs");
    final currentSong = ref.watch(currentSongNotifierProvider);
    final listSong = ref.watch(songListProvider);
    final artists = ref.watch(artistsProvider);
    final genres = ref.watch(genresSongProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: currentSong == null
          ? null
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  hexToColor(currentSong.hexCode),
                  Pallete.transparentColor,
                ],
                stops: const [0.0, 0.3],
              ),
            ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Gần đây bạn đã xem',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Pallete.whiteColor,
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final recentSongs = ref.watch(historyProvider);

                return Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16, bottom: 36),
                  child: SizedBox(
                    height: 150,
                    child: recentSongs.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có bài hát nào được phát gần đây',
                              style: TextStyle(
                                color: Pallete.whiteColor2,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: recentSongs.length,
                            itemBuilder: (context, index) {
                              final song = recentSongs[index];

                              return AnimatedSlide(
                                duration: Duration(milliseconds: 500),
                                offset: Offset(0, 0),
                                curve: Curves.easeOut,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity: 1.0,
                                  curve: Curves.easeIn,
                                  child: GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(currentSongNotifierProvider
                                              .notifier)
                                          .updateSong5(song, recentSongs);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Pallete.borderColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    song.thumbnailUrl),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                bottomLeft: Radius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  song.songName,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(
                                                    height:
                                                        4), // Khoảng cách giữa songName và userName
                                                Text(
                                                  song.userName ?? 'helo',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Được đề xuất cho hôm nay',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Pallete.whiteColor,
                ),
              ),
            ),
            ref.watch(getAllSongsProvider).when(
                  data: (songs) {
                    return SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];

                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(currentSongNotifierProvider.notifier)
                                  .updateSong5(song, songs);
                              ref.read(historyProvider.notifier).addSong(song);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          song.thumbnailUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      song.songName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        overflow: TextOverflow.ellipsis,
                                        color: Pallete.whiteColor,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      song.userName ?? '',
                                      style: const TextStyle(
                                        color: Pallete.whiteColor2,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  error: (error, st) {
                    return Center(
                      child: Text(
                        error.toString(),
                      ),
                    );
                  },
                  loading: () => const Loader(),
                ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Album',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Pallete.whiteColor,
                ),
              ),
            ),
            SizedBox(
              height: 230,
              child: ref.watch(getAlbumsProvider).when(
                    data: (albumsList) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: albumsList.length,
                        itemBuilder: (context, index) {
                          final album = albumsList[index];
                          return GestureDetector(
                            onTap: () {
                              PageNavigation.navigateToChild(
                                  context,
                                  AlbumDetailPage(
                                    album: album,
                                    artname: album.userName ?? '',
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(album.thumbnail_url),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      album.name ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        overflow: TextOverflow.ellipsis,
                                        color: Pallete.whiteColor2,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      album.userName ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        overflow: TextOverflow.ellipsis,
                                        color: Pallete.whiteColor2,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    error: (error, st) => Center(child: Text(error.toString())),
                    loading: () => const Loader(),
                  ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 20),
                  child: Text(
                    'Nghệ sĩ nổi bật',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: artists.when(
                    data: (artistsList) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: artistsList.length,
                        itemBuilder: (context, index) {
                          final artist = artistsList[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistDetailPage(
                                        artistId: artist.id,
                                        artistName: artist.normalizedName,
                                        imageUrl: artist.imageUrl),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: artist.imageUrl == null
                                          ? Pallete.gradient3
                                          : null,
                                      image: artist.imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  artist.imageUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: artist.imageUrl == null
                                        ? Center(
                                            child: Text(
                                              artist.normalizedName.isNotEmpty
                                                  ? artist.normalizedName[0]
                                                      .toUpperCase()
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    artist.normalizedName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Lỗi: $error')),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 30, bottom: 20),
                  child: Text(
                    'Thể loại',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: genres.when(
                    data: (genresList) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: genresList.length,
                        itemBuilder: (context, index) {
                          final genre = genresList[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GenreSongsPage(
                                      genreId: genre.id,
                                      genreName: genre.name,
                                      // artname: genre.name,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140,
                                decoration: BoxDecoration(
                                  color: genre.hex_code != null
                                      ? Color(int.parse(
                                          '0xFF${genre.hex_code!.substring(1)}'))
                                      : Pallete.gradient3,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    if (genre.image_url != null)
                                      Positioned(
                                        right: -20,
                                        bottom: -10,
                                        child: Transform.rotate(
                                          angle: 25 * 3.14159 / 180,
                                          child: Image.network(
                                            genre.image_url!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        genre.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Lỗi: $error')),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tuyển tập nhạc hay',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Pallete.whiteColor,
                ),
              ),
            ),

            Container(
              height: 380,
              width: double.infinity,
              child: ref.watch(getAllSongsProvider).when(
                    data: (songs) {
                      return Stack(
                        children: [
                          // PageView chứa hình ảnh bài hát
                          PageView.builder(
                            controller: _pageController,
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    // Hình ảnh bài hát
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        song.thumbnailUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    // Gradient overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.5),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Controls overlay
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Song info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    song.songName,
                                                    style: const TextStyle(
                                                      color: Pallete.whiteColor,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    song.artists
                                                        .map((artist) => artist
                                                            .normalizedName)
                                                        .join(', '),
                                                    style: TextStyle(
                                                      color: Pallete.whiteColor
                                                          .withOpacity(0.7),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Controls
                                            Consumer(
                                              builder: (context, ref, child) {
                                                final currentSong = ref.watch(
                                                    currentSongNotifierProvider);
                                                final currentSongNotifier =
                                                    ref.watch(
                                                        currentSongNotifierProvider
                                                            .notifier);
                                                final isThisSongPlaying =
                                                    currentSong?.id ==
                                                            song.id &&
                                                        currentSongNotifier
                                                            .isPlaying;

                                                return Row(
                                                  children: [
                                                    // Wave animation hoặc nút 3 chấm
                                                    SizedBox(
                                                      width: 40,
                                                      child: isThisSongPlaying
                                                          ? const WaveDotsAnimation()
                                                          : IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              icon: const Icon(
                                                                Icons
                                                                    .more_horiz,
                                                                color: Pallete
                                                                    .whiteColor,
                                                                size: 24,
                                                              ),
                                                              onPressed: () {},
                                                            ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    // Nút play/pause
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Pallete.greenColor,
                                                      ),
                                                      child: IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        icon: Icon(
                                                          isThisSongPlaying
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: Pallete
                                                              .whiteColor,
                                                          size: 24,
                                                        ),
                                                        onPressed: () {
                                                          if (isThisSongPlaying) {
                                                            currentSongNotifier
                                                                .playPause();
                                                          } else {
                                                            currentSongNotifier
                                                                .updateSong5(
                                                                    song,
                                                                    songs);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Nút điều hướng - cố định ở giữa
                          Positioned.fill(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        color: Pallete.whiteColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Pallete.whiteColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    error: (error, st) => Center(
                      child: Text(error.toString()),
                    ),
                    loading: () => const Loader(),
                  ),
            ),
            const SizedBox(height: 74),
          ],
        ),
      ),
    );
  }
}
