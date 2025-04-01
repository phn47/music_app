import 'package:artist/core/theme/app_colors.dart';
import 'package:artist/models/album.dart';
import 'package:artist/models/song.dart';
import 'package:flutter/material.dart';
import 'package:artist/services/song_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:artist/services/auth_service.dart';
import 'package:artist/services/artist_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final songService = SongService();
  late ArtistService artistService;
  List<Song> songs = [];
  List<Album> albums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    artistService = ArtistService(
        prefs: Provider.of<AuthService>(context, listen: false).prefs);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      await Future.wait([
        _loadSongs(),
        _loadAlbums(),
      ]);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadAlbums() async {
    try {
      final fetchedAlbums = await artistService.getMyAlbums();
      if (mounted) {
        setState(() {
          albums = fetchedAlbums;
        });
      }
    } catch (e) {
      print('Error loading albums: $e');
    }
  }

  Future<void> _loadSongs() async {
    try {
      setState(() => isLoading = true);
      final token =
          await Provider.of<AuthService>(context, listen: false).getToken();

      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final loadedSongs = await songService.getMySongs();
      if (mounted) {
        setState(() {
          songs = loadedSongs;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading songs: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách bài hát: $e')),
        );
      }
    }
  }

  Widget _buildAlbumsSection() {
    if (albums.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Album của bạn',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/albums');
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Card(
                color: AppColors.cardColor,
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/album-detail',
                      arguments: album,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 140,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            album.thumbnailUrl,
                            width: 124,
                            height: 124,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 124,
                              height: 124,
                              color: Colors.grey[850],
                              child: Icon(Icons.album,
                                  color: AppColors.textColorSecondary),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          album.name,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Divider(color: AppColors.textColorSecondary.withOpacity(0.2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Trang chủ',
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
              _loadData();
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
              onRefresh: _loadData,
              color: AppColors.primaryColor,
              child: songs.isEmpty && albums.isEmpty
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
                  : ListView(
                      children: [
                        _buildAlbumsSection(),
                        if (songs.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'Bài hát của bạn',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
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
                                  // TODO: Navigate to song detail
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              song.thumbnailUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
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
                                                  color: AppColors
                                                      .textColorSecondary,
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
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Xác nhận xóa'),
                                              content: Text(
                                                  'Bạn có chắc chắn muốn xóa bài hát này?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: Text('Hủy'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text('Xóa'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await songService
                                                  .deleteSong(song.id);
                                              _loadData();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text('Đã xóa bài hát')),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Không thể xóa bài hát: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
    );
  }
}
