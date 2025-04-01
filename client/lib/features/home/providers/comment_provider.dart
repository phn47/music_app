import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:riverpod/src/framework.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';
import '../../../core/providers/dio_provider.dart';

part 'comment_provider.g.dart';

@Riverpod(keepAlive: true)
CommentRepository commentRepository(CommentRepositoryRef ref) {
  return CommentRepository(ref.watch(dioProvider));
}

@riverpod
class CommentNotifier extends _$CommentNotifier {
  @override
  AsyncValue<List<CommentModel>> build() {
    return const AsyncValue.data([]);
  }

  late AuthLocalRepository _authLocalRepository;
  late String songId;

  Future<void> loadComments(String songId) async {
    try {
      state = const AsyncValue.loading();
      this.songId = songId;
      final repository = ref.read(commentRepositoryProvider);
      final comments = await repository.getComments(songId);
      state = AsyncValue.data(comments);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addComment(String content, String userId) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      await repository.addComment(songId, content, userId);
      await loadComments(songId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> editComment(String commentId, String content) async {
    try {
      _authLocalRepository = ref.read(authLocalRepositoryProvider);
      final token = _authLocalRepository.getToken();
      final repository = ref.read(commentRepositoryProvider);
      await repository.editComment(
          songId: songId,
          commentId: commentId,
          content: content,
          token: token ?? '');
      await loadComments(songId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      _authLocalRepository = ref.read(authLocalRepositoryProvider);
      final token = _authLocalRepository.getToken();
      final repository = ref.read(commentRepositoryProvider);
      await repository.deleteComment(
          songId: songId, commentId: commentId, token: token ?? '');
      await loadComments(songId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
