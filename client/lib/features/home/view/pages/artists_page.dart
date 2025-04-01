import 'dart:async';

import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/models/artist_model.dart';
import 'package:client/features/home/viewmodel/search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/providers/artist_provider.dart';
import 'package:client/features/home/view/pages/artist_detail_page.dart';

class ArtistsPage extends ConsumerStatefulWidget {
  const ArtistsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends ConsumerState<ArtistsPage> {
  bool isGridView = true; // Mặc định là grid view
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Trigger search
      ref.read(artistsProvider.notifier).searchArtists(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final artists = ref.watch(artistsProvider);
    final currentSong = ref.watch(currentSongNotifierProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Title
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Pallete.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Chọn thêm các nghệ sĩ bạn thích.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallete.whiteColor,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              centerTitle: false,
              expandedTitleScale: 1.3,
            ),
          ),
          // Search bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 115,
              maxHeight: 115,
              child: Container(
                color: Pallete.backgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search TextField
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Pallete.whiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm nghệ sĩ...',
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
                                          .read(
                                              searchViewModelProvider.notifier)
                                          .searchSongs11('');
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
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                    // Filter button row
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isGridView ? Icons.grid_view : Icons.view_list,
                              color: Pallete.whiteColor,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                isGridView = !isGridView;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Artists list/grid
          artists.when(
            data: (artistsList) => SliverPadding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: currentSong != null ? 82 : 16,
              ),
              sliver: isGridView
                  ? // Grid View
                  SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildArtistItem(artistsList[index]),
                        childCount: artistsList.length,
                      ),
                    )
                  : // List View
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildListItem(artistsList[index]),
                        ),
                        childCount: artistsList.length,
                      ),
                    ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: Loader()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text('Lỗi: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(ArtistModel artist) {
    return GestureDetector(
      onTap: () => _navigateToArtistDetail(artist),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: artist.imageUrl == null ? Pallete.gradient3 : null,
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
            artist.name ?? 'Unknown Artist',
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
  }

  Widget _buildListItem(ArtistModel artist) {
    return ListTile(
      onTap: () => _navigateToArtistDetail(artist),
      leading: Container(
        width: 80, // Tăng kích thước avatar
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: artist.imageUrl == null ? Pallete.gradient3 : null,
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
      title: Text(
        artist.name ?? 'Unknown Artist',
        style: const TextStyle(
          color: Pallete.whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToArtistDetail(ArtistModel artist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistDetailPage(
          artistId: artist.id,
          artistName: artist.normalizedName,
          imageUrl: artist.imageUrl,
        ),
      ),
    );
  }
}

// Delegate class cho search bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
