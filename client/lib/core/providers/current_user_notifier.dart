import 'package:client/core/models/user_model.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_notifier.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier {
  @override
  UserModel? build() {
    return null;
  }

  void addUser(UserModel user) {
    state = user;
  }

  void removeUser() {
    state = null;
  }

  void updateFavorites(List<FavSongModel> favorites) {
    if (state != null) {
      state = state!.copyWith(favorites: favorites);
    }
  }
}
