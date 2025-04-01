import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/group_messages.dart';
import 'package:client/features/home/models/message_model.dart';
import 'package:client/features/home/view/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupMessageTile extends StatelessWidget {
  final Message message;
  final VoidCallback onLongPress;

  const GroupMessageTile({
    required this.message,
    required this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUser = ref.watch(currentUserNotifierProvider);
        final isMe = currentUser != null && message.senderId == currentUser.id;

        return MessageBubble(
          message: message,
          isMe: isMe,
          onLongPress: onLongPress,
        );
      },
    );
  }
}
