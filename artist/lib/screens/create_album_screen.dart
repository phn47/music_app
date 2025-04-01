import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/artist_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreateAlbumScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const CreateAlbumScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  _CreateAlbumScreenState createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;
  File? _thumbnail;
  late final ArtistService _artistService;

  @override
  void initState() {
    super.initState();
    _artistService = ArtistService(prefs: widget.prefs);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _thumbnail = File(result.files.single.path!);
      });
    }
  }

  Future<void> _createAlbum() async {
    if (!_formKey.currentState!.validate()) return;

    if (_thumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ảnh thumbnail')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _artistService.createAlbum(
        _nameController.text,
        _descriptionController.text,
        _isPublic,
        _thumbnail!,
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo album: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo Album Mới')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Thumbnail picker
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _thumbnail != null
                      ? Image.file(_thumbnail!, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50),
                              Text('Chọn ảnh thumbnail'),
                            ],
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên album',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên album';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Album công khai'),
                value: _isPublic,
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createAlbum,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Tạo album'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
