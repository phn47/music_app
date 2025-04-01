import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:client/features/home/view/pages/album_detail_page.dart';
import 'package:client/features/home/view/pages/upload_album.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/widgets/page_navigation.dart';

class AlbumsPage extends ConsumerWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(getAlbumsProvider);

    return BaseScaffold(
      currentIndex: 3, // Vì đây là trang thuộc Library
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Album',
          style:
              TextStyle(color: Pallete.whiteColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     PageNavigation.navigateToChild(context, const UploadAlbum());
          //   },
          //   icon: const Icon(Icons.add),
          // ),
        ],
      ),
      body: albums.when(
        data: (albumsList) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: albumsList.length,
            itemBuilder: (context, index) {
              final album = albumsList[index];
              return GestureDetector(
                onTap: () {
                  PageNavigation.navigateToChild(
                      context,
                      AlbumDetailPage(
                        album: album,
                        artname: album.userName ?? "",
                      ));
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
          );
        },
        error: (error, stack) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
