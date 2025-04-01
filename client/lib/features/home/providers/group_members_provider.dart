import 'package:client/features/home/models/group_member_model.dart';
import 'package:client/features/home/providers/message_provider.dart';
import 'package:client/features/home/repositories/message_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupMembersProvider = StateNotifierProvider.family<GroupMembersNotifier,
    AsyncValue<List<GroupMember>>, int>((ref, groupId) {
  return GroupMembersNotifier(ref.read(messageRepositoryProvider), groupId);
});

class GroupMembersNotifier
    extends StateNotifier<AsyncValue<List<GroupMember>>> {
  final MessageRepository _repository;
  final int groupId;

  GroupMembersNotifier(this._repository, this.groupId)
      : super(const AsyncValue.loading()) {
    getMembers();
  }

  Future<void> getMembers() async {
    try {
      state = const AsyncValue.loading();
      final members = await _repository.getGroupMembers(groupId);
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
