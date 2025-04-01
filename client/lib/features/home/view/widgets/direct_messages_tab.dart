import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/providers/message_provider.dart';
import 'package:client/features/home/view/pages/direct_message_page.dart';

class DirectMessagesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directChats = ref.watch(directChatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(directChatsProvider.notifier).loadDirectChats();
      },
      child: directChats.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Text('Chưa có cuộc trò chuyện nào'),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final displayName =
                  chat.otherUser.receiver_name.replaceAll('Người dùng ', '');

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(displayName),
                subtitle:
                    chat.lastMessage != null && chat.lastMessage!.isNotEmpty
                        ? Text(
                            chat.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DirectMessagePage(
                        receiverId: chat.otherUser.id,
                        receiverName: chat.otherUser.receiver_name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Lỗi: $error'),
        ),
      ),
    );
  }
}
