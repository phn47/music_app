import 'package:artist/screens/album_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/album.dart';
import '../services/artist_service.dart';
import 'create_album_screen.dart';
import 'create_album_song_screen.dart';

class AlbumScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const AlbumScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late final ArtistService artistService;
  List<Album> albums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    artistService = ArtistService(prefs: widget.prefs);
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedAlbums = await artistService.getMyAlbums();
      setState(() {
        albums = fetchedAlbums;
      });
    } catch (e) {
      print('Error fetching albums: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách album: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAlbumScreen(prefs: widget.prefs),
                ),
              );
              if (result == true) {
                _fetchAlbums();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : albums.isEmpty
              ? Center(child: Text('Bạn chưa phát hành album nào'))
              : ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () async {
                          // Cập nhật để sử dụng AlbumDetailScreen
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AlbumDetailScreen(album: album),
                            ),
                          );
                          if (result == true) {
                            _fetchAlbums();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  album.thumbnailUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[850],
                                      child: Icon(
                                        Icons.album,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              // Album Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (album.description != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        album.description!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Status Icons
                              Icon(
                                album.isPublic
                                    ? Icons.public
                                    : Icons.lock_outline,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Xác nhận xóa'),
                                        content: Text(
                                            'Bạn có chắc chắn muốn xóa album này?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      // Implement delete functionality
                                      // await artistService.deleteAlbum(album.id);
                                      // _fetchAlbums();
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa album'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
