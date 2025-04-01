import 'dart:io';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadAlbum extends ConsumerStatefulWidget {
  const UploadAlbum({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadAlbumState();
}

class _UploadAlbumState extends ConsumerState<UploadAlbum> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  final formKey = GlobalKey<FormState>();

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

  @override
  void dispose() {
    super.dispose();
    songNameController.dispose();
    artistController.dispose();
  }

  void _handleCreateAlbum() async {
    if (formKey.currentState!.validate() && selectedImage != null) {
      await ref.read(homeViewModelProvider.notifier).createAlbum(
            thumbnail: selectedImage!,
            name: songNameController.text,
            isPublic: true, // Hoặc thêm switch để chọn public/private
          );

      if (mounted) {
        // Refresh danh sách albums
        // ignore: unused_result
        ref.refresh(getAlbumsProvider);

        Navigator.pop(context);
        showSnackBar(context, 'Tạo album thành công!');
      }
    } else {
      showSnackBar(context, 'Vui lòng nhập đầy đủ thông tin!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(homeViewModelProvider.select((val) => val?.isLoading == true));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo album'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _handleCreateAlbum,
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
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: selectedImage != null
                            ? SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : DottedBorder(
                                color: Pallete.borderColor,
                                radius: const Radius.circular(10),
                                borderType: BorderType.RRect,
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                child: const SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open,
                                        size: 40,
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        'Chọn hình cho album của bạn',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      CustomField(
                        hintText: 'Tên album',
                        controller: songNameController,
                      ),
                      const SizedBox(height: 20),
                      ColorPicker(
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                        },
                        color: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
