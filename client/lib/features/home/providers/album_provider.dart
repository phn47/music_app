import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/album_model.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  final token = ref.read(currentUserNotifierProvider)!.token;
  final res = await ref.read(homeRepositoryProvider).getAlbums(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
});
