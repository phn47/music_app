import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/providers/album_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/features/home/viewmodel/search_viewmodel.dart';
import 'package:client/features/home/view/pages/album_detail_page.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/home/providers/genre_provider.dart';
import 'package:client/features/home/view/pages/genre_songs_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildGenreGrid() {
    return ref.watch(genresSongProvider).when(
          data: (genres) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return GestureDetector(
                  onTap: () {
                    PageNavigation.navigateToChild(
                      context,
                      GenreSongsPage(
                        genreId: genre.id,
                        genreName: genre.name,
                        // artname:genre.
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(
                          int.parse(genre.hex_code.replaceAll('#', '0xFF'))),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            genre.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (genre.image_url != null)
                          Positioned(
                            right: -15,
                            bottom: -5,
                            child: Transform.rotate(
                              angle: 0.3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    genre.image_url!,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Lỗi: $error',
                style: const TextStyle(color: Colors.white)),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchViewModelProvider);
    final albums = ref.watch(albumsProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          color: Pallete.backgroundColor,
          gradient: _isSearching
              ? null
              : LinearGradient(
                  colors: [Pallete.backgroundColor1, Pallete.backgroundColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Column(
          children: [
            if (_isSearching) const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Bạn muốn nghe gì?',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(searchViewModelProvider.notifier)
                                        .searchSongs('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        onTap: () {
                          _focusNode.requestFocus();
                        },
                        onChanged: (value) {
                          setState(() {});
                          ref
                              .read(searchViewModelProvider.notifier)
                              .searchSongs(value);
                        },
                      ),
                    ),
                  ),
                  if (_isSearching)
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        _focusNode.unfocus();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSearching) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Album được đề xuất',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      albums.when(
                        data: (albumsList) {
                          return SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: albumsList.length,
                              itemBuilder: (context, index) {
                                final album = albumsList[index];
                                return GestureDetector(
                                  onTap: () {
                                    PageNavigation.navigateToChild(
                                        context,
                                        AlbumDetailPage(
                                            album: album,
                                            artname: album.userName ?? ""));
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  album.thumbnail_url),
                                              fit: BoxFit.cover,
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
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Center(child: Text('Lỗi: $error')),
                      ),
                    ],
                    //const SizedBox(height: 10),

                    if (_isSearching) ...[
                      searchResults.when(
                        data: (songs) {
                          if (songs.isEmpty &&
                              _searchController.text.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không tìm thấy kết quả cho "${_searchController.text}"',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (songs.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    'Xem tất cả kết quả cho "${_searchController.text}"',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: songs.length,
                                itemBuilder: (context, index) {
                                  final song = songs[index];
                                  return Card(
                                    color: Colors.white.withOpacity(0.1),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(8),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          song.thumbnailUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey,
                                              child: const Icon(
                                                  Icons.music_note,
                                                  color: Colors.white),
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(song.songName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(song.userName ?? 'hhh',
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      onTap: () {
                                        ref
                                            .read(currentSongNotifierProvider
                                                .notifier)
                                            .updateSong(song);
                                      },
                                    ),
                                  );
                                },
                              ),
                              if (songs.length > 5) ...[
                                const SizedBox(height: 20),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Navigate to full search results page
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Xem tất cả kết quả cho "${_searchController.text}"',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Center(child: Text('Lỗi: $error')),
                      ),
                    ],
                    if (!_isSearching) const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Duyệt tìm tất cả',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildGenreGrid(),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
