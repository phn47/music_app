import 'package:client/core/models/user_model.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/providers/dio_provider.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/home/models/chat_conversation.dart';
import 'package:client/features/home/models/group_chat.dart';
import 'package:client/features/home/models/group_messages.dart';
import 'package:client/features/home/models/message_model.dart';
import 'package:client/features/home/models/send_message_request.dart';
import 'package:client/features/home/repositories/message_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:http/http.dart';

final messageRepositoryProvider = Provider((ref) => MessageRepository(
      dio: ref.read(dioProvider),
      ref: ref,
    ));

final userSearchProvider =
    StateNotifierProvider<UserSearchNotifier, AsyncValue<List<UserModel>>>(
        (ref) {
  return UserSearchNotifier(ref.read(messageRepositoryProvider));
});

final messageProvider =
    StateNotifierProvider<MessageNotifier, AsyncValue<List<Message>>>((ref) {
  return MessageNotifier(
      ref.read(messageRepositoryProvider), ref); // Truyền ref vào
});

final directMessagesProvider = StateNotifierProvider.family<
    DirectMessagesNotifier,
    AsyncValue<List<Message>>,
    String>((ref, receiverId) {
  return DirectMessagesNotifier(
      ref.read(messageRepositoryProvider), receiverId, ref);
});

final groupMessagesProvider = StateNotifierProvider.family<GroupMessageNotifier,
    AsyncValue<List<Message>>, int>((ref, groupId) {
  return GroupMessageNotifier(ref.read(messageRepositoryProvider), groupId);
});

final directChatsProvider = StateNotifierProvider<DirectChatsNotifier,
    AsyncValue<List<ChatConversation>>>((ref) {
  return DirectChatsNotifier(ref.read(messageRepositoryProvider));
});

final groupChatsProvider =
    StateNotifierProvider<GroupChatsNotifier, AsyncValue<List<GroupChat>>>(
        (ref) {
  return GroupChatsNotifier(ref.read(messageRepositoryProvider));
});

class UserSearchNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final MessageRepository _repository;

  UserSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> searchUsers(String query) async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.searchUsers(query);
      state = AsyncValue.data(users);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

class MessageNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final MessageRepository _repository;
  late AuthLocalRepository _authLocalRepository;
  final Ref _ref;

  MessageNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  Future<void> getMessages() async {
    try {
      state = const AsyncValue.loading();
      // Implement logic to get messages
      state = AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(SendMessageRequest request) async {
    try {
      await _repository.sendMessage(request);
      // Refresh messages
      await getMessages();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addReaction(int messageId, String emoji) async {
    try {
      _authLocalRepository = _ref.read(authLocalRepositoryProvider);
      final token = _authLocalRepository.getToken();
      await _repository.addReaction(
          messageId: messageId, emoji: emoji, token: token ?? "");
      await getMessages();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.searchUsers(query);
      state = AsyncValue.data([]); // Update với kết quả tìm kiếm
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addDirectMessage(UserModel user) async {
    try {
      // Tạo hoặc lấy cuộc trò chuyện
      final chatInfo = await _repository.createDirectChat(user.id);

      // Lấy tin nhắn của cuộc trò chuyện
      final messages = await _repository.getDirectMessages(user.id);

      // Cập nhật state với tin nhắn mới
      state = AsyncValue.data(messages);
    } catch (e) {
      print('Error adding direct message: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sendDirectMessage(String receiverId, String content) async {
    try {
      await _repository.sendDirectMessage(receiverId, content);
      // Tự động cập nhật danh sách tin nhắn sau khi gửi
      final messages = await _repository.getDirectMessages(receiverId);
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw e;
    }
  }

  Future<void> refreshMessages(String receiverId) async {
    try {
      final messages = await _repository.getDirectMessages(receiverId);
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class DirectMessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final MessageRepository _repository;
  final String receiverId;
  final Ref ref;
  List<Message> _currentMessages = [];

  DirectMessagesNotifier(this._repository, this.receiverId, this.ref)
      : super(const AsyncValue.loading()) {
    getMessages();
  }

  Future<void> getMessages() async {
    try {
      final currentUser = ref.read(currentUserNotifierProvider);
      if (currentUser == null) return;

      final messages = await _repository.getDirectMessages(receiverId);
      messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));

      // Chỉ cập nhật state nếu có tin nhắn mới
      if (_messagesChanged(messages)) {
        _currentMessages = messages;
        state = AsyncValue.data(messages);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool _messagesChanged(List<Message> newMessages) {
    if (_currentMessages.length != newMessages.length) return true;

    for (int i = 0; i < newMessages.length; i++) {
      if (_currentMessages[i].id != newMessages[i].id) return true;
    }

    return false;
  }

  Future<void> sendMessage(String content) async {
    try {
      final currentUser = ref.read(currentUserNotifierProvider);
      if (currentUser == null) return;

      await _repository.sendDirectMessage(receiverId, content);
      await getMessages();
    } catch (e) {
      // Handle error
    }
  }
}

class GroupMessageNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final MessageRepository _repository;
  final int groupId;
  Timer? _timer;

  GroupMessageNotifier(this._repository, this.groupId)
      : super(const AsyncValue.loading()) {
    getMessages();
    // Bắt đầu polling
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => getMessages());
  }

  Future<void> getMessages() async {
    try {
      final messages = await _repository.getGroupMessages(groupId);
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class DirectChatsNotifier
    extends StateNotifier<AsyncValue<List<ChatConversation>>> {
  final MessageRepository _repository;

  DirectChatsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDirectChats();
  }

  Future<void> loadDirectChats() async {
    try {
      state = const AsyncValue.loading();
      final chats = await _repository.getDirectChats();
      state = AsyncValue.data(chats);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class GroupChatsNotifier extends StateNotifier<AsyncValue<List<GroupChat>>> {
  final MessageRepository _repository;

  GroupChatsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadGroupChats();
  }

  Future<void> loadGroupChats() async {
    try {
      state = const AsyncValue.loading();
      final groups = await _repository.getGroupChats();
      state = AsyncValue.data(groups);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
