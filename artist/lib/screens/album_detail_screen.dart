import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'create_album_song_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({Key? key, required this.album}) : super(key: key);

  @override
  _AlbumDetailScreenState createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final SongService songService = SongService();
  List<Song> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbumSongs();
  }

  Future<void> _fetchAlbumSongs() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Thêm method getAlbumSongs trong SongService
      final fetchedSongs = await songService.getAlbumSongs(widget.album.id);
      setState(() {
        songs = fetchedSongs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách bài hát: $e')),
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
      body: CustomScrollView(
        slivers: [
          // Album Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.album.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.album.thumbnailUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print("Error loading album image: $exception");
                        },
                      ),
                    ),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Album Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album Description
                  if (widget.album.description != null) ...[
                    Text(
                      widget.album.description!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                    ),
                    SizedBox(height: 16),
                  ],

                  // Album Status
                  Row(
                    children: [
                      Icon(
                        widget.album.isPublic
                            ? Icons.public
                            : Icons.lock_outline,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.album.isPublic ? 'Công khai' : 'Riêng tư',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Songs Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bài hát (${songs.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateAlbumSongScreen(album: widget.album),
                            ),
                          );
                          if (result == true) {
                            _fetchAlbumSongs();
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text('Thêm bài hát'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Songs List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : songs.isEmpty
                    ? SliverFillRemaining(
                        child: Center(child: Text('Chưa có bài hát nào')),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = songs[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: NetworkImage(song.thumbnailUrl),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {
                                        print(
                                            "Error loading song image: $exception");
                                      },
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      color: Colors.grey[850]!.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                title: Text(song.songName),
                                subtitle: song.playCount != null
                                    ? Text('${song.playCount} lượt nghe')
                                    : null,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Xác nhận xóa'),
                                          content: Text(
                                              'Bạn có chắc chắn muốn xóa bài hát này?'),
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
                                        try {
                                          await songService.deleteSong(song.id);
                                          _fetchAlbumSongs();
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
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Xóa bài hát'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: songs.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
