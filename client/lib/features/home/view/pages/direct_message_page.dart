import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/home/models/message_model.dart';
import 'package:client/features/home/models/send_message_request.dart';
import 'package:client/features/home/providers/message_provider.dart';
import 'package:client/features/home/view/widgets/edit_message_dialog.dart';
import 'package:client/features/home/view/widgets/message_bubble.dart';
import 'package:client/features/home/view/widgets/message_input.dart';
import 'package:client/features/home/view/widgets/reaction_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../widgets/message_options_sheet.dart';

class DirectMessagePage extends ConsumerStatefulWidget {
  final String receiverId;
  final String receiverName;

  const DirectMessagePage({
    required this.receiverId,
    required this.receiverName,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DirectMessagePage> createState() => _DirectMessagePageState();
}

class _DirectMessagePageState extends ConsumerState<DirectMessagePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isInputFocused = false;
  late FocusNode _focusNode;
  Timer? _refreshTimer;
  late AuthLocalRepository _authLocalRepository;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    // Thiết lập timer để refresh tin nhắn mỗi 1 giây
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        ref
            .read(directMessagesProvider(widget.receiverId).notifier)
            .getMessages();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _refreshTimer?.cancel(); // Hủy timer khi widget bị dispose
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isInputFocused = _focusNode.hasFocus;
    });
  }

  String _getAvatarText(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? content]) async {
    final messageContent = content ?? _messageController.text.trim();
    if (messageContent.isEmpty) return;

    try {
      await ref
          .read(directMessagesProvider(widget.receiverId).notifier)
          .sendMessage(messageContent);
      _messageController.clear();

      // Không cần gọi refresh vì đã có timer tự động refresh
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi tin nhắn thất bại: ${e.toString()}')),
      );
    }
  }

  String _getUserName(String userId) {
    final currentUser = ref.read(currentUserNotifierProvider);
    if (currentUser?.id == userId) {
      return currentUser?.name ?? 'Bạn';
    }
    return widget.receiverName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.purple,
              child: Text(
                _getAvatarText(_getUserName(widget.receiverId)),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getUserName(widget.receiverId),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final messagesAsync =
                    ref.watch(directMessagesProvider(widget.receiverId));

                return messagesAsync.when(
                  data: (messages) {
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId ==
                            ref.read(currentUserNotifierProvider)?.id;

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          onLongPress: () => _showMessageOptions(message),
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Lỗi: $error',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                // Các nút chức năng bên trái với animation
                // AnimatedContainer(
                //   duration: Duration(milliseconds: 200),
                //   width: _isInputFocused ? 0 : 192, // 48 * 4 icons
                //   child: _isInputFocused
                //       ? null
                //       : SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Row(
                //             children: [
                //               IconButton(
                //                 icon:
                //                     Icon(Icons.add_circle, color: Colors.blue),
                //                 onPressed: () {},
                //                 padding: EdgeInsets.all(12),
                //                 constraints: BoxConstraints(),
                //               ),
                //               IconButton(
                //                 icon:
                //                     Icon(Icons.camera_alt, color: Colors.blue),
                //                 onPressed: () {},
                //                 padding: EdgeInsets.all(12),
                //                 constraints: BoxConstraints(),
                //               ),
                //               IconButton(
                //                 icon: Icon(Icons.photo, color: Colors.blue),
                //                 onPressed: () {},
                //                 padding: EdgeInsets.all(12),
                //                 constraints: BoxConstraints(),
                //               ),
                //               IconButton(
                //                 icon: Icon(Icons.mic, color: Colors.blue),
                //                 onPressed: () {},
                //                 padding: EdgeInsets.all(12),
                //                 constraints: BoxConstraints(),
                //               ),
                //             ],
                //           ),
                //         ),
                // ),
                // Khung nhập tin nhắn với animation
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            style: TextStyle(color: Colors.white),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _sendMessage();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Aa',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions, color: Colors.blue),
                          onPressed: () {},
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Nút like
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.blue),
                  onPressed: () => _sendMessage('👍'),
                  padding: EdgeInsets.all(12),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageOptionsSheet(
        message: message,
        onEdit: () => _editMessage(message),
        onDelete: () => _deleteMessage(message),
        onReact: () => _showReactionPicker(message),
      ),
    );
  }

  void _editMessage(Message message) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditMessageDialog(
        initialText: message.content,
      ),
    );

    if (result != null) {
      try {
        await ref
            .read(messageRepositoryProvider)
            .editMessage(message.id, result);
        ref
            .read(directMessagesProvider(widget.receiverId).notifier)
            .getMessages();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit message: ${e.toString()}')),
        );
      }
    }
  }

  void _deleteMessage(Message message) async {
    final currentUser = ref.read(currentUserNotifierProvider);
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(messageRepositoryProvider)
            .deleteMessage(message.id, currentUser.id);
        ref
            .read(directMessagesProvider(widget.receiverId).notifier)
            .getMessages();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: ${e.toString()}')),
        );
      }
    }
  }

  void _showReactionPicker(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReactionPicker(
        onReactionSelected: (emoji) async {
          Navigator.pop(context);
          try {
            _authLocalRepository = ref.read(authLocalRepositoryProvider);
            final token = _authLocalRepository.getToken();
            final messageId = int.parse(message.id);
            final recipientId = message.receiverId;
            await ref.read(messageRepositoryProvider).reactToMessage(
                messageId: messageId,
                emoji: emoji,
                token: token ?? '',
                recipientId: recipientId ?? "");
            // Refresh messages to show new reaction
            ref
                .read(directMessagesProvider(widget.receiverId).notifier)
                .getMessages();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to add reaction: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }
}
