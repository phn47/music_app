import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class Giaodientruyendulieu extends ConsumerStatefulWidget {
  const Giaodientruyendulieu({super.key});

  @override
  ConsumerState<Giaodientruyendulieu> createState() =>
      _GiaodientruyendulieuState();
}

class _GiaodientruyendulieuState extends ConsumerState<Giaodientruyendulieu> {
  final AudioController = TextEditingController();
  final LrcController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    AudioController.dispose();
    LrcController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        AudioController.text = result.files.first.path ?? '';
      });
    }
  }

  Future<void> _pickLrcFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        LrcController.text = result.files.first.path ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Thêm file LRC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn tệp âm thanh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: _pickAudioFile,
                    leading: const Icon(
                      Icons.audio_file,
                      color: Colors.purple,
                      size: 32,
                    ),
                    title: Text(
                      AudioController.text.isEmpty
                          ? 'Chọn file audio'
                          : AudioController.text.split('/').last,
                      style: TextStyle(
                        color: AudioController.text.isEmpty
                            ? Colors.grey
                            : Colors.white,
                      ),
                    ),
                    trailing: AudioController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () =>
                                setState(() => AudioController.clear()),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chọn tệp LRC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: _pickLrcFile,
                    leading: const Icon(
                      Icons.description,
                      color: Colors.blue,
                      size: 32,
                    ),
                    title: Text(
                      LrcController.text.isEmpty
                          ? 'Chọn file LRC'
                          : LrcController.text.split('/').last,
                      style: TextStyle(
                        color: LrcController.text.isEmpty
                            ? Colors.grey
                            : Colors.white,
                      ),
                    ),
                    trailing: LrcController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () =>
                                setState(() => LrcController.clear()),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final token = await ref
                            .read(authLocalRepositoryProvider)
                            .getToken();
                        if (token != null) {
                          final audioData =
                              await File(AudioController.text).readAsBytes();
                          final audioFileName =
                              AudioController.text.split('/').last;

                          final result =
                              await ref.read(homeRepositoryProvider).trainModel(
                                    audioData: audioData,
                                    lrcPath: LrcController.text,
                                    audioFileName: audioFileName,
                                  );

                          if (Right == null) {
                            showSnackBar(context, 'Truyền dữ liệu thất bại');
                          } else {
                            showSnackBar(context, 'Truyền dữ liệu thành công');
                          }
                        } else {
                          showSnackBar(context,
                              'Token không hợp lệ, vui lòng đăng nhập lại');
                        }
                      } else {
                        showSnackBar(context, 'Vui lòng chọn đầy đủ file');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bắt đầu huấn luyện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
