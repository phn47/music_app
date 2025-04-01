import 'dart:io';

import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/base_scaffold.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/view/pages/giaodientruyendulieu.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';

class YourUploadPage extends ConsumerWidget {
  const YourUploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSongs = ref.watch(getUserSongsProvider);
    ref.watch(currentSongNotifierProvider);

    return BaseScaffold(
      currentIndex: 3,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bài Hát Của Bạn',
            style: TextStyle(
              color: Pallete.whiteColor,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF333333),
                      hintText: 'Tìm kiếm bài hát',
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(FontAwesomeIcons.slidersH,
                      color: Colors.white),
                  onSelected: (value) {
                    // Xử lý logic sắp xếp ở đây
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'Recently added',
                        child: Text('Mới nhất'),
                      ),
                      const PopupMenuItem(
                        value: 'First added',
                        child: Text('Thêm đầu tiên'),
                      ),
                      const PopupMenuItem(
                        value: 'All songs',
                        child: Text('Tất cả bài hát'),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Giaodientruyendulieu()),
                );
              },
              child: Row(
                children: [
                  Container(
                    color: const Color(0xFF333333),
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Thêm file LRC',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadSongPage()),
                );
              },
              child: Row(
                children: [
                  Container(
                    color: const Color(0xFF333333),
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Thêm Bài Hát',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: userSongs.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bạn chưa tải lên bài hát nào',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Image.network(
                        song.thumbnailUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.white),
                          );
                        },
                      ),
                      title: Text(
                        song.songName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        song.artists
                            .map((artist) => artist.normalizedName)
                            .join(', '),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context, ref, song);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, ref, song);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Sửa'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa'),
                          ),
                        ],
                      ),
                      onTap: () {
                        ref
                            .read(currentSongNotifierProvider.notifier)
                            .updateSong(song);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Có lỗi xảy ra: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, SongModel song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text(
          'Xóa bài hát',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa bài hát này?',
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
                  .deleteSong(song.id);
              if (context.mounted) {
                showSnackBar(context, 'Đã xóa bài hát');
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, SongModel song) {
    final songNameController = TextEditingController(text: song.songName);
    final artistController = TextEditingController(
        text: song.artists.map((artist) => artist.normalizedName).join(', '));
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text(
          'Sửa bài hát',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomField(
                hintText: 'Tên bài hát',
                controller: songNameController,
              ),
              const SizedBox(height: 10),
              CustomField(
                hintText: 'Nghệ sĩ',
                controller: artistController,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage = await pickImage();
                  if (pickedImage != null) {
                    selectedImage = pickedImage;
                  }
                },
                child: const Text('Chọn ảnh mới'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(homeViewModelProvider.notifier).updateSong(
                    songId: song.id,
                    songName: songNameController.text.trim(),
                    artistName: artistController.text.trim(),
                    thumbnail: selectedImage,
                  );
              if (context.mounted) {
                showSnackBar(context, 'Đã cập nhật bài hát');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
