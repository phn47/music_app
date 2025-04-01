import 'dart:io';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/providers/artist_provider.dart';
import 'package:client/features/home/view/widgets/audio_wave.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadAlbumSongPage extends ConsumerStatefulWidget {
  final String albumId;

  const UploadAlbumSongPage({
    super.key,
    required this.albumId,
  });

  @override
  ConsumerState<UploadAlbumSongPage> createState() =>
      _UploadAlbumSongPageState();
}

class _UploadAlbumSongPageState extends ConsumerState<UploadAlbumSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? selectedAudio;
  File? selectedImage;
  Color selectedColor = Colors.blue;
  File? selectedArtistImage;

  @override
  void dispose() {
    super.dispose();
    songNameController.dispose();
    artistController.dispose();
  }

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  void selectArtistImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        selectedArtistImage = pickedImage;
      });
    }
  }

  void _handleUpload() async {
    if (formKey.currentState!.validate() &&
        selectedAudio != null &&
        selectedImage != null) {
      await ref.read(homeViewModelProvider.notifier).uploadSongToAlbum(
            albumId: widget.albumId,
            selectedAudio: selectedAudio!,
            selectedThumbnail: selectedImage!,
            songName: songNameController.text.trim(),
            artist: artistController.text.trim(),
            selectedColor: selectedColor,
            artistImage: selectedArtistImage,
          );

      if (mounted) {
        // Refresh danh sách bài hát trong album
        ref.invalidate(getAlbumSongsProvider(widget.albumId));
        // Refresh danh sách nghệ sĩ
        ref.invalidate(artistsProvider);

        Navigator.pop(context);
        showSnackBar(context, 'Thêm bài hát vào album thành công!');
      }
    } else {
      showSnackBar(context, 'Vui lòng nhập đầy đủ thông tin!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(homeViewModelProvider)?.isLoading ?? false;

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Thêm bài hát vào album'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _handleUpload,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh bìa
                      GestureDetector(
                        onTap: selectImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Pallete.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            image: selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 40,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Chọn ảnh bìa',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // File âm thanh
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Pallete.cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: selectedAudio != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'File âm thanh đã chọn',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AudioWave(path: selectedAudio!.path),
                                ],
                              )
                            : ListTile(
                                onTap: selectAudio,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.audio_file_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                title: Text(
                                  'Chọn file âm thanh',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 25),

                      // Thông tin bài hát
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Pallete.cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin bài hát',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomField(
                              hintText: 'Tên bài hát',
                              controller: songNameController,
                            ),
                            const SizedBox(height: 15),
                            CustomField(
                              hintText: 'Nghệ sĩ',
                              controller: artistController,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Chọn màu
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Pallete.cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: selectedColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Màu chủ đạo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ColorPicker(
                              height: 35,
                              enableOpacity: false,
                              color: selectedColor,
                              onColorChanged: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              pickersEnabled: const {
                                ColorPickerType.wheel: true,
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Ảnh nghệ sĩ
                      buildArtistImageSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildArtistImageSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Pallete.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ảnh nghệ sĩ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: selectArtistImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: selectedArtistImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            selectedArtistImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedArtistImage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 40,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Thêm ảnh nghệ sĩ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hỗ trợ định dạng PNG, JPG',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
