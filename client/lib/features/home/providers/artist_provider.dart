import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/providers/dio_provider.dart';
import 'package:client/features/home/models/artist_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/models/artist_model.dart' as artist;
import 'package:client/features/home/repositories/artist_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/models/album_model.dart';

final artistRepositoryProvider = Provider((ref) => ArtistRepository());

final artistsProvider =
    StateNotifierProvider<ArtistsNotifier, AsyncValue<List<ArtistModel>>>(
        (ref) {
  return ArtistsNotifier(ref);
});

class ArtistsNotifier extends StateNotifier<AsyncValue<List<ArtistModel>>> {
  final Ref _ref;
  String _currentQuery = '';

  ArtistsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadArtists();
  }

  Future<void> loadArtists() async {
    state = const AsyncValue.loading();
    final token = _ref.read(currentUserNotifierProvider)!.token;
    final repository = _ref.read(artistRepositoryProvider);

    final result = await repository.getArtists(
      token: token,
      query: _currentQuery,
    );

    state = switch (result) {
      Left(value: final failure) =>
        AsyncValue.error(failure.message, StackTrace.current),
      Right(value: final artists) => AsyncValue.data(artists),
    };
  }

  Future<void> searchArtists(String query) async {
    _currentQuery = query;
    await loadArtists();
  }
}

final artistDetailProvider =
    FutureProvider.family<artist.ArtistModel, String>((ref, artistId) async {
  final token = ref.read(currentUserNotifierProvider)!.token;
  final repository = ref.read(artistRepositoryProvider);

  final result = await repository.getArtistDetail(
    artistId: artistId,
    token: token,
  );

  return switch (result) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
});

final artistSongsProvider = FutureProvider.family<List<SongModel>, String>(
  (ref, artistId) async {
    final token = ref.read(currentUserNotifierProvider)!.token;
    final res = await http.get(
      Uri.parse('${ServerConstant.serverURL}/auth/artist/$artistId/songs'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );
    print(res);

    if (res.statusCode != 200) {
      throw Exception('Không thể lấy danh sách bài hát');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => SongModel.fromMap(e)).toList();
  },
);

final artistAlbumsProvider = FutureProvider.family<List<AlbumModel>, String>(
  (ref, artistId) async {
    final token = ref.read(currentUserNotifierProvider)!.token;
    final res = await http.get(
      Uri.parse('${ServerConstant.serverURL}/auth/artist/$artistId/albums'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Không thể lấy danh sách album');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => AlbumModel.fromMap(e)).toList();
  },
);

final followedArtistsProvider = FutureProvider<List<ArtistModel>>((ref) async {
  try {
    final dio = ref.read(dioProvider);
    final token = ref.read(currentUserNotifierProvider)?.token;

    if (token == null) {
      throw 'Unauthorized';
    }

    final response = await dio.get(
      '${ServerConstant.serverURL}/auth/artist/followed',
      options: Options(
        headers: {
          'x-auth-token': token,
        },
      ),
    );

    if (response.data is List) {
      return (response.data as List).map((json) {
        // Lấy thông tin người dùng từ trường "user" trong dữ liệu
        final user = json['user'] != null ? json['user'] : {};

        return ArtistModel(
          id: json['id'],
          normalizedName: json['normalizedName'],
          bio: json['bio'],
          imageUrl: json['imageUrl'],
          isApproved: json['isApproved'],
          userId: user['id'], // Lấy userId từ trường "user"
          name: json['name'] ?? '',
          createdAt: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null,
          updatedAt: json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null,
        );
      }).toList();
    }

    return [];
  } catch (e) {
    throw e.toString();
  }
});
