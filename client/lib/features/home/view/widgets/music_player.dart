import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/widgets/marquee_text.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/providers/repeatNotifier.dart';
import 'package:client/features/home/providers/song_list_provider.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import '../widgets/comment_section.dart';
import 'package:client/features/home/providers/playlist_provider.dart';

final GlobalKey<_MusicPlayerState> key = GlobalKey<_MusicPlayerState>();
final isRepeatProvider = StateProvider<bool>((ref) => false);

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String lyrics = ""; // Biến để lưu trữ lời bài hát
  List<String> lyricsLines = [];
  List<int> pauseDurations = [];
  List<Duration> lyricsTimestamps = [];
  // Danh sách các dòng lời bài hát
  int currentLyricIndex = 0; // Chỉ số của dòng lời bài hát hiện tại
  final String apiKey = 'd08f08eb84a844bc89362173f0e75bef';
  late AudioPlayer _audioPlayer; // Khai báo AudioPlayer
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final currentSong = ref.read(currentSongNotifierProvider);
    _audioPlayer = AudioPlayer();
    _audioPlayer.positionStream.listen((position) {
      updateLyrics(position);
    });
    fetchSongInfo(currentSong!.songUrl);
  }

  Future<void> fetchSongInfo(String songUrl) async {
    try {
      final encodedUrl = Uri.encodeComponent(songUrl);
      final response = await http.get(Uri.parse(
          'https://api.audd.io/?url=$encodedUrl&api_token=d08f08eb84a844bc89362173f0e75bef'));

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        final parsedData = json.decode(data);

        final result = parsedData['result'];
        if (result != null) {
          await Loi(result['artist'], result['title'], result['timecode']);
        } else {
          setState(() {
            lyrics = "Không tìm thấy thông tin bài hát";
          });
        }
      } else {
        setState(() {
          lyrics = "Lỗi khi lấy thông tin bài hát";
        });
      }
    } catch (e) {
      setState(() {
        lyrics = "Lỗi: $e";
      });
    }
  }

  Future<void> Loi(String artist, String title, String timecode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.lyrics.ovh/v1/$artist/$title'),
      );

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        final parsedData = json.decode(data);

        if (parsedData.containsKey('lyrics')) {
          final lyrics = parsedData['lyrics'];
          await fetchLyrics(lyrics);
        } else {
          setState(() {
            lyrics = "Không tìm thấy lời bài hát trong dữ liệu API.";
          });
        }
      } else {
        setState(() {
          lyrics =
              "Lỗi khi lấy thông tin bài hát từ API Lyric.ovh. Mã lỗi: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        lyrics = "Lỗi: $e";
      });
    }
  }

  Future<void> fetchLyrics(String lyrics) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}/song/compare-lyrics/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lyrics': lyrics,
        }),
      );

      if (response.statusCode == 200) {
        final data = utf8.decode(response.bodyBytes);
        final parsedData = json.decode(data);

        final lrcData = parsedData['matching_files'][0]['lyrics'];

        setState(() {
          this.lyrics = lrcData;
        });

        parseLrcData(lrcData);
      } else {
        setState(() {
          lyrics = "Lỗi khi lấy lời bài hát từ API ChatGPT";
        });
      }
    } catch (e) {
      setState(() {
        lyrics = "Lỗi: $e";
      });
    }
  }

  void parseLrcData(String lrcData) {
    lyricsLines = [];
    lyricsTimestamps = [];

    for (var line in lrcData.split('\n')) {
      final match =
          RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)').firstMatch(line);

      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!);

        lyricsLines.add(match.group(4)!.trim());
        lyricsTimestamps.add(
          Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: milliseconds,
          ),
        );
      }
    }
  }

  void updateLyrics(Duration currentPosition) {
    if (lyricsLines.isEmpty || lyricsTimestamps.isEmpty) return;

    for (int i = 0; i < lyricsTimestamps.length; i++) {
      final lyricDuration = lyricsTimestamps[i];

      if (currentPosition >= lyricDuration) {
        if (mounted) {
          setState(() {
            currentLyricIndex = i;
          });
        }
      }
    }
  }

  void _showAddToPlaylistBottomSheet(
      BuildContext context, WidgetRef ref, SongModel currentSong) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thêm vào danh sách phát',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Pallete.whiteColor,
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final playlistsAsync = ref.watch(playlistsProvider);

                  return playlistsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text(
                      'Có lỗi xảy ra: $error',
                      style: const TextStyle(color: Pallete.whiteColor),
                    ),
                    data: (playlists) => Expanded(
                      child: ListView.builder(
                        itemCount: playlists.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              leading: const Icon(
                                Icons.add,
                                color: Pallete.whiteColor,
                              ),
                              title: const Text(
                                'Tạo danh sách phát mới',
                                style: TextStyle(color: Pallete.whiteColor),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => CreatePlaylistDialog(
                                    currentSong: currentSong,
                                  ),
                                );
                              },
                            );
                          }

                          final playlist = playlists[index - 1];
                          final isSongInPlaylist =
                              playlist.songs.any((s) => s.id == currentSong.id);

                          return ListTile(
                            title: Text(
                              playlist.name,
                              style: const TextStyle(color: Pallete.whiteColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSongInPlaylist ? Icons.remove : Icons.add,
                                color: Pallete.whiteColor,
                              ),
                              onPressed: () async {
                                try {
                                  if (isSongInPlaylist) {
                                    await ref
                                        .read(playlistsProvider.notifier)
                                        .removeSongFromPlaylist(
                                          playlist.id,
                                          currentSong.id,
                                        );
                                  } else {
                                    await ref
                                        .read(playlistsProvider.notifier)
                                        .addSongToPlaylist(
                                          playlist.id,
                                          currentSong,
                                        );
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isSongInPlaylist
                                              ? 'Đã xóa bài hát khỏi danh sách phát'
                                              : 'Đã thêm bài hát vào danh sách phát',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final currentUser = ref.watch(currentUserNotifierProvider);
    final userFavorites = ref
        .watch(currentUserNotifierProvider.select((data) => data!.favorites));
    final isRepeat = ref.watch(isRepeatProvider);
    final songList = ref.watch(songListProvider);
    final currentSongNotifier = ref.watch(currentSongNotifierProvider.notifier);
    final isPressed = ref.watch(repeatNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hexToColor(currentSong!.hexCode),
            const Color(0xff121212),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Pallete.transparentColor,
        appBar: AppBar(
          backgroundColor: Pallete.transparentColor,
          leading: Transform.translate(
            offset: const Offset(-15, 0),
            child: InkWell(
              highlightColor: Pallete.transparentColor,
              focusColor: Pallete.transparentColor,
              splashColor: Pallete.transparentColor,
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/pull-down-arrow.png",
                  color: Pallete.whiteColor,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.comment, color: Pallete.whiteColor),
              onPressed: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          children: [
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Hero(
                            tag: 'music-image',
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(currentSong.thumbnailUrl),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MarqueeText(
                                        text: currentSong.songName,
                                        style: const TextStyle(
                                          color: Pallete.whiteColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      MarqueeText(
                                        text: currentSong.userName ?? '',
                                        style: const TextStyle(
                                          color: Pallete.greyColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (currentUser != null) {
                                      try {
                                        await ref
                                            .read(
                                                homeViewModelProvider.notifier)
                                            .toggleFavorite(
                                              songId: currentSong.id,
                                              userId: currentUser.id,
                                            );
                                      } catch (e) {
                                        if (context.mounted) {
                                          showSnackBar(context, e.toString());
                                        }
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    userFavorites
                                            .where((fav) =>
                                                fav.song_id == currentSong.id)
                                            .toList()
                                            .isNotEmpty
                                        ? CupertinoIcons.heart_fill
                                        : CupertinoIcons.heart,
                                    color: Pallete.whiteColor,
                                    size: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showAddToPlaylistBottomSheet(
                                        context, ref, currentSong);
                                  },
                                  icon: const Icon(
                                    Icons.playlist_add,
                                    color: Pallete.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            StreamBuilder<Duration>(
                              stream: currentSongNotifier
                                  .audioPlayer?.positionStream,
                              builder: (context, snapshot) {
                                final currentPosition =
                                    snapshot.data ?? Duration.zero;
                                final totalDuration =
                                    currentSongNotifier.audioPlayer?.duration ??
                                        Duration.zero;
                                final progress =
                                    totalDuration.inMilliseconds > 0
                                        ? currentPosition.inMilliseconds /
                                            totalDuration.inMilliseconds
                                        : 0.0;

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  updateLyrics(currentPosition);
                                });

                                return Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Pallete.whiteColor,
                                        inactiveTrackColor: Pallete.whiteColor
                                            .withOpacity(0.117),
                                        thumbColor: Pallete.whiteColor,
                                        trackHeight: 4,
                                        overlayShape:
                                            SliderComponentShape.noOverlay,
                                      ),
                                      child: Slider(
                                        value: progress,
                                        onChanged: (value) async {
                                          final newPosition =
                                              totalDuration * value;
                                          await currentSongNotifier.audioPlayer
                                              ?.seek(newPosition);
                                        },
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(currentPosition),
                                          style: const TextStyle(
                                            color: Pallete.whiteColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(totalDuration),
                                          style: const TextStyle(
                                            color: Pallete.whiteColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(height: 15),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 16.0),
                                    //   child: Text(
                                    //     currentLyricIndex < lyricsLines.length
                                    //         ? lyricsLines[currentLyricIndex]
                                    //         : "Đang tải lời bài hát...",
                                    //     style: const TextStyle(
                                    //       fontSize: 16,
                                    //       color: Colors.white54,
                                    //     ),
                                    //     textAlign: TextAlign.center,
                                    //   ),
                                    // ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          ref
                              .read(currentSongNotifierProvider.notifier)
                              .playRandom(songList);
                        },
                        icon: const Icon(
                          CupertinoIcons.shuffle,
                          color: Pallete.whiteColor,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final songListAsync = ref.watch(songProvider);
                          songListAsync.when(
                            data: (songProvider) {
                              currentSongNotifier.playPrevious(songList);
                            },
                            loading: () {},
                            error: (error, stack) {
                              print('Error loading songs: $error');
                            },
                          );
                        },
                        icon: Image.asset(
                          'assets/images/previus-song.png',
                          color: Pallete.whiteColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final audioPlayer = currentSongNotifier.audioPlayer;
                          if (audioPlayer != null) {
                            currentSongNotifier.playPause();
                          }
                        },
                        icon: Icon(
                          (currentSongNotifier.audioPlayer?.playing == true)
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                          size: 80,
                          color: Pallete.whiteColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final songListAsync = ref.watch(songProvider);
                          songListAsync.when(
                            data: (songProvider) {
                              currentSongNotifier.playNextSong(songList);
                            },
                            loading: () {},
                            error: (error, stack) {
                              print('Error loading songs: $error');
                            },
                          );
                        },
                        icon: Image.asset(
                          'assets/images/next-song.png',
                          color: Pallete.whiteColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(isRepeatProvider.notifier).state = !isRepeat;
                        },
                        icon: Icon(
                          isRepeat
                              ? CupertinoIcons.repeat_1
                              : CupertinoIcons.repeat,
                          color:
                              isRepeat ? Pallete.gradient2 : Pallete.whiteColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CommentSection(
              songId: currentSong.id,
              userId: ref.read(currentUserNotifierProvider)!.id,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

class CreatePlaylistDialog extends ConsumerStatefulWidget {
  final SongModel currentSong;

  const CreatePlaylistDialog({
    super.key,
    required this.currentSong,
  });

  @override
  ConsumerState<CreatePlaylistDialog> createState() =>
      _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends ConsumerState<CreatePlaylistDialog> {
  final textController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Pallete.backgroundColor,
      title: const Text(
        'Danh sách phát mới',
        style: TextStyle(
          color: Pallete.whiteColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: textController,
        style: const TextStyle(color: Pallete.whiteColor),
        decoration: const InputDecoration(
          hintText: 'Đặt tên cho danh sách phát của bạn',
          hintStyle: TextStyle(color: Pallete.greyColor),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Pallete.greyColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Pallete.gradient2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Pallete.greyColor),
          ),
        ),
        TextButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (textController.text.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final notifier = ref.read(playlistsProvider.notifier);
                      // Tạo playlist mới
                      await notifier.createPlaylist(textController.text);

                      // Lấy playlist vừa tạo (playlist cuối cùng)
                      final playlists = ref.read(playlistsProvider).value ?? [];
                      if (playlists.isNotEmpty) {
                        final newPlaylist = playlists.last;
                        // Thêm bài hát vào playlist mới
                        await notifier.addSongToPlaylist(
                          newPlaylist.id,
                          widget.currentSong,
                        );
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Đã tạo danh sách phát và thêm bài hát'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Pallete.gradient2,
                  ),
                )
              : const Text(
                  'Tạo',
                  style: TextStyle(color: Pallete.gradient2),
                ),
        ),
      ],
    );
  }
}
