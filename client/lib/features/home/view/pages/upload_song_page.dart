// ignore_for_file: unused_result, unused_local_variable

import 'dart:io';
import 'package:client/core/providers/current_song_notifier.dart';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/providers/artist_provider.dart';
import 'package:client/features/home/providers/genre_provider.dart';
import 'package:client/features/home/view/widgets/audio_wave.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  File? selectedArtistImage;
  final formKey = GlobalKey<FormState>();
  final List<String> selectedArtists = [];
  final List<String> selectedGenres = [];

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

  @override
  void dispose() {
    super.dispose();
    songNameController.dispose();
    artistController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(homeViewModelProvider)?.isLoading ?? false;

    // Cache kết quả trong 5 phút
    final userSongs = ref.watch(getUserSongsProvider.select((value) => value));
    ref.watch(currentSongNotifierProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Tải lên bài hát'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: uploadSong,
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
                          child: Stack(
                            children: [
                              if (selectedImage == null)
                                Center(
                                  child: Column(
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
                                  ),
                                ),
                              if (selectedImage != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImage = null;
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
                          ),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.purple
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.music_note,
                                                color: Colors.purple.shade300,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'File âm thanh',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    selectedAudio!.path
                                                        .split('/')
                                                        .last,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedAudio = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  GestureDetector(
                                    onTap: selectAudio,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.purple.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child:
                                          AudioWave(path: selectedAudio!.path),
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: selectAudio,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.audio_file_outlined,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 40,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Chọn file âm thanh',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Hỗ trợ định dạng MP3, WAV',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
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
                              'Nghệ sĩ và Thể loại',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Widget chọn nghệ sĩ
                            MultiSelectDialogField<String>(
                              items: ref.watch(artistsProvider).when(
                                    data: (artists) => artists
                                        .map((artist) => MultiSelectItem(
                                            artist.id, artist.normalizedName))
                                        .toList(),
                                    loading: () => [],
                                    error: (_, __) => [],
                                  ),
                              title: const Text('Chọn nghệ sĩ'),
                              selectedColor: Colors.purple,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              buttonText: const Text(
                                'Chọn nghệ sĩ',
                                style: TextStyle(color: Colors.white70),
                              ),
                              onConfirm: (values) {
                                setState(() {
                                  selectedArtists.clear();
                                  selectedArtists.addAll(values);
                                });
                              },
                            ),

                            const SizedBox(height: 15),

                            // Widget chọn thể loại
                            MultiSelectDialogField<String>(
                              items: ref.watch(genresProvider).when(
                                    data: (genres) => genres
                                        .map((genre) => MultiSelectItem(
                                            genre.id, genre.name))
                                        .toList(),
                                    loading: () => [],
                                    error: (_, __) => [],
                                  ),
                              title: const Text('Chọn thể loại'),
                              selectedColor: Colors.purple,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              buttonText: const Text(
                                'Chọn thể loại',
                                style: TextStyle(color: Colors.white70),
                              ),
                              onConfirm: (values) {
                                setState(() {
                                  selectedGenres.clear();
                                  selectedGenres.addAll(values);
                                });
                              },
                            ),
                          ],
                        ),
                      ),

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

  void uploadSong() async {
    if (formKey.currentState!.validate() &&
        selectedAudio != null &&
        selectedImage != null &&
        selectedArtists.isNotEmpty &&
        selectedGenres.isNotEmpty) {
      await ref.read(homeViewModelProvider.notifier).uploadSong(
            selectedAudio: selectedAudio!,
            selectedThumbnail: selectedImage!,
            songName: songNameController.text.trim(),
            artistNames: [artistController.text.trim()],
            genreIds: selectedGenres,
            selectedColor: selectedColor,
            artistImages:
                selectedArtistImage != null ? [selectedArtistImage!] : null,
          );

      if (mounted) {
        ref.invalidate(getUserSongsProvider);
        ref.invalidate(artistsProvider);
        Navigator.pop(context);
        showSnackBar(context, 'Tải lên bài hát thành công!');
      }
    } else {
      showSnackBar(
          context, 'Vui lòng nhập đầy đủ thông tin và chọn nghệ sĩ, thể loại!');
    }
  }
}
