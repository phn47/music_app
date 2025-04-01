import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/home/view/pages/artist_detail_page.dart';
import 'package:client/features/home/view/pages/playlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/liked_tracks_page.dart';
import 'package:client/features/home/view/pages/your_upload_page.dart';
import 'package:client/features/home/view/pages/albums_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/providers/artist_provider.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongs = ref.watch(getFavSongsProvider);
    final followedArtists = ref.watch(followedArtistsProvider);
    final currentSong = ref.watch(currentSongNotifierProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: RefreshIndicator(
        color: Pallete.gradient2,
        backgroundColor: Pallete.backgroundColor,
        onRefresh: () async {
          await Future.wait([
            ref.refresh(getFavSongsProvider.future),
            ref.refresh(followedArtistsProvider.future),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  context,
                  'Bộ sưu tập của bạn',
                  [
                    _buildMenuItem(context, 'Bài hát ưa thích', Icons.favorite,
                        () {
                      PageNavigation.navigateToChild(
                          context, const LikedTracksPage());
                    }),
                    _buildMenuItem(
                        context, 'Danh sách phát', Icons.queue_music_outlined,
                        () {
                      PageNavigation.navigateToChild(
                          context, const PlaylistPage());
                    }),
                  ],
                ),
                _buildSection(
                  context,
                  'Nghệ sĩ đã theo dõi',
                  [
                    _buildFollowedArtists(ref),
                  ],
                ),
                _buildSection(
                  context,
                  'Bài hát gần đây',
                  [
                    _buildRecentSongs(ref),
                  ],
                ),
                SizedBox(height: currentSong != null ? 66 + 16 : 16),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Pallete.whiteColor),
      title: Text(title, style: TextStyle(color: Pallete.whiteColor)),
      trailing: Icon(Icons.chevron_right, color: Pallete.whiteColor),
      onTap: onTap,
    );
  }

  Widget _buildRecentSongs(WidgetRef ref) {
    final recentSongs = ref.watch(getFavSongsProvider);
    return recentSongs.when(
      data: (songs) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(song.thumbnailUrl),
                radius: 25,
              ),
              title: Text(song.songName,
                  style: TextStyle(color: Pallete.whiteColor)),
              subtitle: Text(
                  song.artists
                      .map((artist) => artist.normalizedName)
                      .join(', '),
                  style: TextStyle(color: Pallete.greyColor)),
              onTap: () {
                ref.read(currentSongNotifierProvider.notifier).updateSong(song);
              },
            );
          },
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
    );
  }

  Widget _buildFollowedArtists(WidgetRef ref) {
    final followedArtists = ref.watch(followedArtistsProvider);

    return followedArtists.when(
      data: (artists) {
        if (artists.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bạn chưa theo dõi nghệ sĩ nào',
              style: TextStyle(color: Pallete.greyColor),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return GestureDetector(
              onTap: () {
                PageNavigation.navigateToChild(
                  context,
                  ArtistDetailPage(
                    artistId: artist.id,
                    artistName: artist.normalizedName,
                    imageUrl: artist.imageUrl,
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            artist.imageUrl == null ? Pallete.gradient3 : null,
                        image: artist.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(artist.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: artist.imageUrl == null
                          ? Center(
                              child: Text(
                                artist.normalizedName.isNotEmpty
                                    ? artist.normalizedName[0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Pallete.whiteColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist.name ?? artist.normalizedName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Pallete.whiteColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
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
    );
  }
}
