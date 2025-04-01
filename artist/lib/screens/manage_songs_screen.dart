import 'package:artist/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'upload_song_screen.dart';

class ManageSongsScreen extends StatefulWidget {
  @override
  _ManageSongsScreenState createState() => _ManageSongsScreenState();
}

class _ManageSongsScreenState extends State<ManageSongsScreen> {
  final songService = SongService();
  List<Song> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      setState(() => isLoading = true);
      final fetchedSongs = await songService.getMySongs();
      setState(() {
        songs = fetchedSongs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách bài hát: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quản lý bài hát',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () async {
              await Navigator.pushNamed(context, '/upload-song');
              _loadSongs(); // Reload after adding new song
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSongs,
              color: AppColors.primaryColor,
              child: songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.queue_music,
                            size: 80,
                            color: AppColors.textColorSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có bài hát nào',
                            style: TextStyle(
                              color: AppColors.textColorSecondary,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/upload-song');
                            },
                            icon: Icon(Icons.add),
                            label: Text('Thêm bài hát mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Card(
                          color: AppColors.cardColor,
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              // TODO: Navigate to edit song
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          song.thumbnailUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[850],
                                            child: Icon(Icons.music_note,
                                                color: AppColors
                                                    .textColorSecondary),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black54,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.songName,
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.headphones,
                                              size: 16,
                                              color:
                                                  AppColors.textColorSecondary,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${song.playCount ?? 0} lượt nghe',
                                              style: TextStyle(
                                                color: AppColors
                                                    .textColorSecondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: AppColors.primaryColor),
                                    onPressed: () {
                                      // TODO: Navigate to edit song
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // TODO: Show delete confirmation
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
