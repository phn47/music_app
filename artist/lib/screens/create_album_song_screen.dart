import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../services/song_service.dart';
import '../core/theme/app_colors.dart';
import '../models/album.dart';
import '../models/artist.dart';

class CreateAlbumSongScreen extends StatefulWidget {
  final Album album;

  const CreateAlbumSongScreen({Key? key, required this.album})
      : super(key: key);

  @override
  _CreateAlbumSongScreenState createState() => _CreateAlbumSongScreenState();
}

class _CreateAlbumSongScreenState extends State<CreateAlbumSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final songNameController = TextEditingController();
  Color selectedColor = AppColors.cardColor;
  File? selectedImage;
  File? selectedAudio;
  bool isLoading = false;
  final songService = SongService();
  List<String> selectedGenres = [];
  List<String> selectedArtists = [];
  List<dynamic> genres = []; // Danh sách thể loại từ API
  late List<Map<String, dynamic>> artists = []; // Danh sách nghệ sĩ từ API
  List<String> selectedGenreIds = [];
  List<String> selectedArtistIds = [];
  List<String> selectedFeaturingArtistIds = [];
  final SongService _songService = SongService();

  @override
  void initState() {
    super.initState();
    _loadGenresAndArtists();
  }

  Future<void> _loadGenresAndArtists() async {
    try {
      setState(() => isLoading = true);
      final genreList = await songService.getGenres();
      final artistList = await songService.fetchArtists();

      // Debug print
      print('Received artist list: $artistList');

      setState(() {
        genres = genreList;
        artists = artistList;
        isLoading = false;
      });

      // Print debug data after setting state
      _printDebugData();
    } catch (e) {
      print('Lỗi khi tải danh sách: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm bài hát vào ${widget.album.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Selection
                Center(
                  child: GestureDetector(
                    onTap: selectImage,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Song Name Input
                TextFormField(
                  controller: songNameController,
                  decoration: InputDecoration(
                    labelText: 'Tên bài hát',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên bài hát';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Color Picker
                ListTile(
                  title: Text('Màu chủ đạo'),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onTap: () => showColorPicker(),
                ),
                SizedBox(height: 20),

                // Audio File Selection
                Center(
                  child: ElevatedButton.icon(
                    onPressed: selectAudio,
                    icon: Icon(Icons.audio_file),
                    label: Text(selectedAudio != null
                        ? 'Đã chọn file âm thanh'
                        : 'Chọn file âm thanh'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Genre Selection
                _buildGenreSelection(),
                SizedBox(height: 20),

                // Featured Artists Selection
                ListTile(
                  title: Text('Nghệ sĩ hát cùng'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _showArtistDialog(),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: selectedArtists
                      .map((artist) => Chip(
                            label: Text(artist),
                            onDeleted: () {
                              setState(() {
                                selectedArtists.remove(artist);
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 30),

                // Upload Button
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _uploadSong,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Tải lên bài hát'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
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

  void selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
    }
  }

  void selectAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        selectedAudio = File(result.files.single.path!);
      });
    }
  }

  void showColorPicker() async {
    final Color color = await showColorPickerDialog(
      context,
      selectedColor,
      title: Text('Chọn màu chủ đạo'),
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 0,
      wheelDiameter: 165,
      enableOpacity: true,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.wheel: true,
      },
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      actionButtons: const ColorPickerActionButtons(
        dialogActionButtons: true,
      ),
    );
    setState(() {
      selectedColor = color;
    });
  }

  Future<void> _showArtistDialog() async {
    try {
      final artists = await _songService.fetchArtists();
      print('Available artists from API: $artists');

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          List<String> tempSelectedIds = List.from(selectedFeaturingArtistIds);
          List<Map<String, dynamic>> tempSelectedArtists =
              List.from(selectedArtists);

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Chọn nghệ sĩ hát cùng'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      final isSelected = tempSelectedIds.contains(artist['id']);

                      return CheckboxListTile(
                        title: Text(artist['name']),
                        subtitle: Text('Artist ID: ${artist['id']}'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelectedIds.add(artist['id']);
                              tempSelectedArtists.add(artist);
                              print(
                                  'Added artist: ${artist['name']} (${artist['id']})');
                            } else {
                              tempSelectedIds.remove(artist['id']);
                              tempSelectedArtists
                                  .removeWhere((a) => a['id'] == artist['id']);
                              print(
                                  'Removed artist: ${artist['name']} (${artist['id']})');
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () {
                      this.setState(() {
                        selectedFeaturingArtistIds.clear();
                        selectedFeaturingArtistIds.addAll(tempSelectedIds);
                        selectedArtists.clear();
                        selectedArtists
                            .addAll(tempSelectedArtists.map((a) => a['id']));
                        print(
                            'Final selected artists: ${selectedArtists.join(", ")}');
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Xong'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error selecting artists: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _uploadSong() async {
    if (_formKey.currentState!.validate() &&
        selectedAudio != null &&
        selectedImage != null) {
      setState(() => isLoading = true);
      try {
        await songService.uploadSongToAlbum(
          song: selectedAudio!,
          thumbnail: selectedImage!,
          songName: songNameController.text.trim(),
          hexCode: selectedColor.value.toRadixString(16),
          genreIds: selectedGenreIds,
          // artistNames: selectedArtistIds,
          featuringArtistIds: selectedFeaturingArtistIds,
          albumId: widget.album.id,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thêm bài hát vào album thành công')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm bài hát: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    songNameController.dispose();
    super.dispose();
  }

  Widget _buildGenreSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thể loại',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: genres.map<Widget>((genre) {
            final Map<String, dynamic> genreMap = genre as Map<String, dynamic>;
            final isSelected = selectedGenreIds.contains(genreMap['id']);

            return FilterChip(
              label: Text(
                genreMap['name'].toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  // Nếu đã có genre được chọn và đang cố chọn genre khác
                  if (selectedGenreIds.isNotEmpty && selected && !isSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chỉ được chọn một thể loại'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Xử lý chọn/bỏ chọn genre
                  if (selected) {
                    selectedGenreIds = [
                      genreMap['id'].toString()
                    ]; // Chỉ lưu một genre ID
                  } else {
                    selectedGenreIds.remove(genreMap['id'].toString());
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: AppColors.cardColor,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildArtistSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          children: artists.map((artist) {
            return FilterChip(
              label: Text(artist['name']?.toString() ?? ''),
              selected: selectedArtists.contains(artist['name']),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedArtists.add(artist['name']?.toString() ?? '');
                    selectedArtistIds.add(artist['id']?.toString() ?? '');
                  } else {
                    selectedArtists.remove(artist['name']?.toString() ?? '');
                    selectedArtistIds.remove(artist['id']?.toString() ?? '');
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: AppColors.cardColor,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Thêm hàm debug để kiểm tra dữ liệu
  void _printDebugData() {
    print('Artists data:');
    for (var artist in artists) {
      print('Artist: $artist');
      print('Type: ${artist.runtimeType}');
    }
  }
}
