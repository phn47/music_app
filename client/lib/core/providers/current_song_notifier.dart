// ignore_for_file: await_only_futures, unused_result

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:client/features/home/models/song2_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/providers/song_list_provider.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  bool isRepeatEnabled = false;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(
      Uri.parse(song.songUrl),
      tag: MediaItem(
        id: song.id,
        title: song.songName,
        artist: song.artists.map((artist) => artist.normalizedName).join(', '),
        artUri: Uri.parse(song.thumbnailUrl),
      ),
    );
    await audioPlayer!.setAudioSource(audioSource);

    audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;

        this.state = this.state?.copyWith(hexCode: this.state?.hexCode);
      }
    });
    _homeLocalRepository.uploadLocalSong(song.toMap());
    audioPlayer!.play();
    isPlaying = true;
    state = song;
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(hexCode: state?.hexCode);
  }

  void seek(double val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }

  void playNext(List<SongModel> songList) {
    final currentSong = state;

    // Kiểm tra nếu chế độ lặp lại đang bật
    if (isRepeatEnabled && currentSong != null) {
      // Nếu chế độ lặp lại đang bật, phát lại bài hát hiện tại
      updateSong5(currentSong, songList);
      return; // Kết thúc hàm sau khi phát lại bài hát hiện tại
    }

    // Nếu không ở chế độ lặp li, tiếp tục phát bài hát tiếp theo
    if (currentSong != null) {
      final currentIndex = songList.indexOf(currentSong);
      final nextIndex = (currentIndex + 1) % songList.length;
      final nextSong = songList[nextIndex];
      updateSong5(nextSong, songList);
    }
  }

  void playNextSong(List<SongModel> songList) {
    if (songList.isEmpty) {
      print("Danh sách bài hát trống.");
      return;
    }

    final currentSong = state; // Lấy bài hát hiện tại từ state
    if (currentSong == null) {
      print("Không có bài hát hiện tại.");
      return;
    }

    final currentIndex = songList.indexOf(currentSong);
    // if (currentIndex == -1) {
    //   print("Bài hát hiện tại không có trong danh sách.");
    //   return;
    // }

    final nextIndex = (currentIndex + 1) %
        songList.length; // Sử dụng toán tử modulo để quay lại đầu danh sách

    final nextSong = songList[nextIndex];

    // Cập nhật bài hát hiện tại và phát bài hát trước đó
    updateSong5(nextSong, songList); // Truyền songList để phát bài hát
  }

  void playRandom(List<SongModel> songList) {
    // Kiểm tra xem danh sách bài hát có ít nhất một bài không
    if (songList.isEmpty) {
      print('Song list is empty. Cannot play random song.');
      return; // Không làm gì c nếu danh sách bài hát rỗng
    }

    // Chọn một bài hát ngẫu nhiên trong danh sách
    final random = Random();
    SongModel randomSong = songList[random.nextInt(songList.length)];

    updateSong5(randomSong, songList); // Phát bài hát ngẫu nhiên đã chọn
  }

  void playPrevious(List<SongModel> songList) async {
    if (songList.isEmpty) {
      print("Danh sách bài hát trống.");
      return;
    }

    final currentSong = state; // Lấy bài hát hiện tại từ state
    if (currentSong == null) {
      print("Không có bài hát hiện tại.");
      return;
    }

    final currentIndex = songList.indexOf(currentSong);
    // if (currentIndex == -1) {
    //   print("Bài hát hiện tại không có trong danh sách.");
    //   return;
    // }

    final previousIndex =
        (currentIndex - 1) < 0 ? songList.length - 1 : currentIndex - 1;
    final previousSong = songList[previousIndex];
    if (key.currentState != null) {
      await key.currentState!.fetchSongInfo(previousSong.songUrl);
    }
    // Cập nhật bài hát hiện tại và phát bài hát trước đó
    updateSong5(previousSong, songList); // Truyền songList để phát bài hát
  }

  // Hàm để lặp lại bài hát
  void repeatSong() {
    if (isRepeatEnabled) {
      print("Đang lặp lại bài hát hiện tại.");
      playCurrentSong();
    } else {
      print("Chế độ lặp lại không bật.");
    }
  }

  // Hàm để chuyển đổi chế độ lặp lại
  void toggleRepeat() {
    isRepeatEnabled = !isRepeatEnabled;
    print(isRepeatEnabled
        ? "Chế độ lặp lại đang bật."
        : "Chế độ lặp lại đang tắt.");
  }

// Hàm để phát bài hát hiện tại
  void playCurrentSong() {
    final currentSong = state; // Lấy bài hát hiện tại từ state

    if (currentSong != null) {
      updateSong3(
          currentSong); // Gọi hàm với bài hát và truyền null cho songList
    } else {
      print("Không có bài hát hiện tại.");
    }
  }

  void updateSong3(SongModel currentSong) {
    state = currentSong;
  }

  // void updateSong5(SongModel song, List<SongModel> songs) async {
  //   audioPlayer ??= AudioPlayer();

  //   try {
  //     // Tạo MediaItem từ thông tin bài hát
  //     final mediaItem = MediaItem(
  //       id: song.id,
  //       title: song.songName,
  //       artist: song.artists.map((artist) => artist.normalizedName).join(', '),
  //       artUri: Uri.parse(song.thumbnailUrl),
  //     );

  //     // Tạo AudioSource với metadata
  //     final audioSource = AudioSource.uri(
  //       Uri.parse(song.songUrl),
  //       tag: mediaItem,
  //     );

  //     await audioPlayer!.setAudioSource(audioSource);

  //     audioPlayer!.playerStateStream.listen((state) {
  //       if (state.processingState == ProcessingState.completed) {
  //         playNext(songs);
  //       }
  //     });

  //     // Lưu bài hát vào local storage
  //     await _homeLocalRepository.uploadLocalSong(song.toMap());

  //     // Lưu vào danh sách gần đây
  //     await ref.read(recentlyPlayedSongsProvider.notifier).addSong(song);

  //     await audioPlayer!.play();
  //     isPlaying = true;
  //     state = song;
  //   } catch (e) {
  //     print("Lỗi khi cập nhật bài hát: $e");
  //   }
  // }

  void dispose() {
    if (audioPlayer != null) {
      audioPlayer!.stop();
      audioPlayer!.dispose();
      audioPlayer = null;
    }
    isPlaying = false;
    state = null;
  }

  void updateSong5(SongModel song, List<SongModel> songs) async {
    audioPlayer ??= AudioPlayer();
    Timer? playTimer;
    bool isPlayCountUpdated = false; // Đảm bảo chỉ gọi API 1 lần

    try {
      // Tạo MediaItem từ thông tin bài hát
      final mediaItem = MediaItem(
        id: song.id,
        title: song.songName,
        artist: song.artists.map((artist) => artist.normalizedName).join(', '),
        artUri: Uri.parse(song.thumbnailUrl),
      );

      // Tạo AudioSource với metadata
      final audioSource = AudioSource.uri(
        Uri.parse(song.songUrl),
        tag: mediaItem,
      );

      await audioPlayer!.setAudioSource(audioSource);

      // Lắng nghe trạng thái phát
      audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.ready &&
            !isPlayCountUpdated) {
          // Đặt timer để gọi API sau 3 giây phát
          playTimer?.cancel();
          playTimer = Timer(Duration(seconds: 3), () {
            incrementPlayCount(song.id); // Gọi API cập nhật lượt nghe
            isPlayCountUpdated = true; // Đảm bảo chỉ gọi API một lần
          });
        } else if (state.processingState == ProcessingState.completed) {
          playNext(songs);
        }
      });

      // Lưu bài hát vào local storage
      await _homeLocalRepository.uploadLocalSong(song.toMap());

      // Lưu vào danh sách gần đây
      await ref.read(recentlyPlayedSongsProvider.notifier).addSong(song);

      await audioPlayer!.play();
      isPlaying = true;
      state = song;
    } catch (e) {
      print("Lỗi khi cập nhật bài hát: $e");
    } finally {
      playTimer?.cancel(); // Hủy timer nếu có lỗi hoặc bài hát kết thúc
    }
  }

  Future<void> incrementPlayCount(String songId) async {
    final url = Uri.parse("http://10.0.2.2:8000/songs/song/play/${songId}");
    try {
      // Dữ liệu JSON body
      final body = jsonEncode({
        // "song_id": songId,
      });

      // Header định nghĩa kiểu dữ liệu
      final headers = {
        "Content-Type": "application/json",
      };

      // Gửi yêu cầu POST
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // Xử lý phản hồi từ server
      if (response.statusCode == 200) {
        print("Cập nhật lượt nghe thành công cho bài hát: $songId");
      } else {
        print("Lỗi khi cập nhật lượt nghe: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối API: $e");
    }
  }
}
