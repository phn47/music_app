// ignore_for_file: unused_result

import 'dart:io';
import 'dart:ui';

import 'package:client/core/models/user_model.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/models/album_model.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/providers/artist_provider.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(GetAllSongsRef ref) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(
        token: token,
      );

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<SongModel>> getFavSongs(GetFavSongsRef ref) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getFavSongs(
        token: token,
      );

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<AlbumModel>> getAlbums(GetAlbumsRef ref) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAlbums(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<SongModel>> getAlbumSongs(
  GetAlbumSongsRef ref,
  String albumId,
) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAlbumSongs(
        albumId: albumId,
        token: token,
      );

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<AlbumModel>> getAllAlbums(GetAllAlbumsRef ref) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAlbums(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required List<String> artistNames,
    required List<String> genreIds,
    required Color selectedColor,
    List<File>? artistImages,
  }) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.uploadSong(
      selectedAudio: selectedAudio,
      selectedThumbnail: selectedThumbnail,
      songName: songName,
      artistNames: artistNames,
      genreIds: genreIds,
      hexCode: selectedColor.value.toRadixString(16).substring(2),
      artistImages: artistImages,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    ref.invalidate(getUserSongsProvider);
    ref.invalidate(artistsProvider);
  }

  List<SongModel> getRecentlyPlayedSongs() {
    return _homeLocalRepository.loadSongs();
  }

  Future<void> favSong({required String songId}) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.favSong(
      songId: songId,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    final val = switch (res) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => _favSongSuccess(r, songId),
    };
    print(val);
  }

  AsyncValue _favSongSuccess(bool isFavorited, String songId) {
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    if (isFavorited) {
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
          favorites: [
            ...ref.read(currentUserNotifierProvider)!.favorites,
            FavSongModel(
              id: '',
              song_id: songId,
              user_id: '',
            ),
          ],
        ),
      );
    } else {
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
              favorites: ref
                  .read(currentUserNotifierProvider)!
                  .favorites
                  .where(
                    (fav) => fav.song_id != songId,
                  )
                  .toList(),
            ),
      );
    }
    ref.invalidate(getFavSongsProvider);
    return state = AsyncValue.data(isFavorited);
  }

  Future<void> createAlbum({
    required File thumbnail,
    required String name,
    required bool isPublic,
  }) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.createAlbum(
      thumbnail: thumbnail,
      name: name,
      isPublic: isPublic,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });
  }

  Future<void> addSongToAlbum({
    required String albumId,
    required String songId,
  }) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.addSongToAlbum(
      albumId: albumId,
      songId: songId,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    // Refresh danh sách bài hát trong album
    ref.invalidate(getAlbumSongsProvider(albumId));
  }

  Future<void> deleteAlbum(String albumId) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.deleteAlbum(
      albumId: albumId,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    // Refresh danh sách albums
    ref.invalidate(getAlbumsProvider);
  }

  Future<void> toggleAlbumPrivacy({
    required String albumId,
    required bool isPublic,
  }) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.updateAlbum(
      albumId: albumId,
      isPublic: !isPublic,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    // Refresh danh sách albums
    ref.invalidate(getAlbumsProvider);
  }

  Future<void> uploadSongToAlbum({
    required String albumId,
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required Color selectedColor,
    File? artistImage,
  }) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.uploadSongToAlbum(
      albumId: albumId,
      selectedAudio: selectedAudio,
      selectedThumbnail: selectedThumbnail,
      songName: songName,
      artist: artist,
      hexCode: selectedColor.value.toRadixString(16).substring(2),
      artistImage: artistImage,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    // Refresh danh sách bài hát trong album
    ref.invalidate(getAlbumSongsProvider(albumId));
  }

  AsyncValue<List<AlbumModel>> getAllAlbums() {
    return ref.watch(getAllAlbumsProvider);
  }

  Future<void> deleteSong(String songId) async {
    state = const AsyncValue.loading();

    // Kiểm tra xem bài hát bị xóa có phải là bài hát đang phát không
    final currentSong = ref.read(currentSongNotifierProvider);
    if (currentSong != null && currentSong.id == songId) {
      ref.read(currentSongNotifierProvider.notifier).dispose();
    }

    final res = await _homeRepository.deleteSong(
      songId: songId,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    // Refresh danh sách bài hát
    ref.invalidate(getUserSongsProvider);
  }

  Future<void> updateSong({
    required String songId,
    String? songName,
    String? artistName,
    String? hexCode,
    File? thumbnail,
  }) async {
    state = const AsyncValue.loading();

    final res = await _homeRepository.updateSong(
      songId: songId,
      songName: songName,
      artistName: artistName,
      hexCode: hexCode,
      thumbnail: thumbnail,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = await AsyncValue.guard(() async {
      return switch (res) {
        Left(value: final l) => throw l.message,
        Right(value: final r) => r,
      };
    });

    // Refresh danh sách bài hát
    ref.invalidate(getUserSongsProvider);
  }

  Future<void> toggleFavorite({
    required String songId,
    required String userId,
  }) async {
    try {
      final res = await ref.read(homeRepositoryProvider).favSong(
            songId: songId,
            token: ref.read(currentUserNotifierProvider)!.token,
          );

      state = await AsyncValue.guard(() async {
        return switch (res) {
          Left(value: final l) => throw l.message,
          Right(value: final r) => await _handleFavoritesUpdate(),
        };
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<List<SongModel>> _handleFavoritesUpdate() async {
    final favSongsRes = await ref.read(homeRepositoryProvider).getFavSongs(
          token: ref.read(currentUserNotifierProvider)!.token,
        );

    switch (favSongsRes) {
      case Left(value: final l):
        throw l.message;
      case Right(value: final r):
        // Chuyển đổi List<SongModel> thành List<FavSongModel>
        final favSongs = r
            .map((song) => FavSongModel(
                  id: '', // ID sẽ được tạo tự động bởi server
                  song_id: song.id,
                  user_id: ref.read(currentUserNotifierProvider)!.id,
                ))
            .toList();
        ref
            .read(currentUserNotifierProvider.notifier)
            .updateFavorites(favSongs);
        return r;
    }
  }
}

final getUserSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final token = ref.read(currentUserNotifierProvider)!.token;

  final res = await ref.read(homeRepositoryProvider).getUserSongs(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
});

@riverpod
Future<List<UserModel>> getAllUser(GetAllUserRef ref) async {
  final token = ref.watch(currentUserNotifierProvider)!.token;
  final res = await ref.watch(homeRepositoryProvider).getAllUser(
        token: token,
      );

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}
