import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:fpdart/fpdart.dart';

part 'search_viewmodel.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  late HomeRepository _homeRepository;

  @override
  AsyncValue<List<SongModel>> build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    return const AsyncValue.data([]);
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    final res = await _homeRepository.searchSongs(
      query: query,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = switch (res) {
      Left(value: final l) => AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => AsyncValue.data(r),
    };
  }

  Future<void> searchSongs11(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    final res = await _homeRepository.searchSongs11(
      query: query,
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    state = switch (res) {
      Left(value: final l) => AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => AsyncValue.data(r),
    };
  }
}
