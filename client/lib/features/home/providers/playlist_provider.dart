import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/playlist_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/playlist_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Provider cho state
final playlistsProvider =
    StateNotifierProvider<PlaylistNotifier, AsyncValue<List<PlaylistModel>>>(
        (ref) {
  final repository = ref.watch(playlistRepositoryProvider);
  return PlaylistNotifier(repository: repository, ref: ref);
});

// Provider cho stream
final playlistsStreamProvider = StreamProvider<List<PlaylistModel>>((ref) {
  final repository = ref.watch(playlistRepositoryProvider);
  final userId = ref.watch(currentUserNotifierProvider)?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.watchPlaylists(userId);
});

class PlaylistNotifier extends StateNotifier<AsyncValue<List<PlaylistModel>>> {
  final PlaylistRepository _repository;
  final Ref _ref;
  final _uuid = const Uuid();

  PlaylistNotifier({
    required PlaylistRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(const AsyncValue.loading()) {
    _loadPlaylists();
    _setupStreamListener();
  }

  void _setupStreamListener() {
    _ref.listen<AsyncValue<List<PlaylistModel>>>(
      playlistsStreamProvider,
      (previous, next) {
        next.whenData((playlists) {
          state = AsyncValue.data(playlists);
        });
      },
    );
  }

  Future<void> _loadPlaylists() async {
    try {
      final userId = _ref.read(currentUserNotifierProvider)?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final playlists = await _repository.getPlaylists(userId);
      if (!mounted) return;
      state = AsyncValue.data(playlists);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      final user = _ref.read(currentUserNotifierProvider);
      if (user == null) return;

      final newPlaylist = PlaylistModel(
        id: _uuid.v4(),
        name: name,
        userId: user.id,
        songs: [],
        createdAt: DateTime.now(),
      );

      final currentPlaylists = state.value ?? [];
      final updatedPlaylists = [...currentPlaylists, newPlaylist];
      await _repository.savePlaylists(user.id, updatedPlaylists);

      if (!mounted) return;
      state = AsyncValue.data(updatedPlaylists);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    try {
      final user = _ref.read(currentUserNotifierProvider);
      if (user == null) return;

      final currentPlaylists = state.value ?? [];
      final updatedPlaylists = currentPlaylists.map((playlist) {
        if (playlist.id == playlistId) {
          final updatedSongs = [...playlist.songs];
          if (!updatedSongs.any((s) => s.id == song.id)) {
            updatedSongs.add(song);
          }
          return playlist.copyWith(songs: updatedSongs);
        }
        return playlist;
      }).toList();

      await _repository.savePlaylists(user.id, updatedPlaylists);

      if (!mounted) return;
      state = AsyncValue.data(updatedPlaylists);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final user = _ref.read(currentUserNotifierProvider);
      if (user == null) return;

      final currentPlaylists = state.value ?? [];
      final updatedPlaylists = currentPlaylists.map((playlist) {
        if (playlist.id == playlistId) {
          final updatedSongs =
              playlist.songs.where((s) => s.id != songId).toList();
          return playlist.copyWith(songs: updatedSongs);
        }
        return playlist;
      }).toList();

      await _repository.savePlaylists(user.id, updatedPlaylists);

      if (!mounted) return;
      state = AsyncValue.data(updatedPlaylists);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePlaylistName(String playlistId, String newName) async {
    try {
      final user = _ref.read(currentUserNotifierProvider);
      if (user == null) return;

      state.whenData((playlists) async {
        final updatedPlaylists = playlists.map((playlist) {
          if (playlist.id == playlistId) {
            return playlist.copyWith(name: newName);
          }
          return playlist;
        }).toList();

        await _repository.savePlaylists(user.id, updatedPlaylists);
        state = AsyncValue.data(updatedPlaylists);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      final user = _ref.read(currentUserNotifierProvider);
      if (user == null) return;

      state.whenData((playlists) async {
        final updatedPlaylists =
            playlists.where((p) => p.id != playlistId).toList();
        await _repository.savePlaylists(user.id, updatedPlaylists);
        state = AsyncValue.data(updatedPlaylists);
      });
    } catch (e) {
      rethrow;
    }
  }
}
