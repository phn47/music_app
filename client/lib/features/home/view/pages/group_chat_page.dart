import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/home/models/message_model.dart';
import 'package:client/features/home/providers/message_provider.dart';
import 'package:client/features/home/view/widgets/edit_message_dialog.dart';
import 'package:client/features/home/view/widgets/group_members_list.dart';
import 'package:client/features/home/view/widgets/group_message_tile.dart';
import 'package:client/features/home/view/widgets/message_bubble.dart';
import 'package:client/features/home/view/widgets/message_input.dart';
import 'package:client/features/home/view/widgets/message_options_sheet.dart';
import 'package:client/features/home/view/widgets/reaction_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupChatPage extends ConsumerStatefulWidget {
  final int groupId;
  final String groupName;
  final String creatorId;

  const GroupChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.creatorId,
  }) : super(key: key);

  @override
  ConsumerState<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends ConsumerState<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInputFocused = false;
  late AuthLocalRepository _authLocalRepository;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isInputFocused = _focusNode.hasFocus;
      });
    });

    Future.microtask(() {
      ref.read(groupMessagesProvider(widget.groupId).notifier).getMessages();
      _scrollToBottom(immediate: true);
    });
  }

  void _scrollToBottom({bool immediate = false}) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage([String? content]) async {
    try {
      final messageContent = content ?? _messageController.text.trim();
      if (messageContent.isEmpty) return;

      await ref.read(messageRepositoryProvider).sendGroupMessage(
            widget.groupId,
            messageContent,
          );

      // Clear input và refresh messages
      _messageController.clear();
      ref.read(groupMessagesProvider(widget.groupId).notifier).getMessages();

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(() {});
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showGroupActions() {
    final currentUser = ref.read(currentUserNotifierProvider);
    if (currentUser?.id != widget.creatorId) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Thêm thành viên'),
            onTap: () => _showAddMemberDialog(),
          ),
          ListTile(
            leading: Icon(Icons.block),
            title: Text('Cấm tất cả thành viên'),
            onTap: () => _banAllMembers(),
          ),
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Gỡ cấm tất cả'),
            onTap: () => _unbanAllMembers(),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm thành viên'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Nhập ID người dùng',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _addMember(textController.text);
              }
              Navigator.pop(context);
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMember(String userId) async {
    try {
      await ref.read(messageRepositoryProvider).addMemberToGroup(
            widget.groupId,
            userId,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm thành viên thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể thêm thành viên: ${e.toString()}')),
      );
    }
  }

  Future<void> _banAllMembers() async {
    try {
      await ref.read(messageRepositoryProvider).banAllMembers(widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cấm tất cả thành viên')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cấm thành viên: ${e.toString()}')),
      );
    }
  }

  Future<void> _unbanAllMembers() async {
    try {
      await ref.read(messageRepositoryProvider).unbanAllMembers(widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gỡ cấm tất cả thành viên')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gỡ cấm thành viên: ${e.toString()}')),
      );
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
                token: token ?? "",
                recipientId: recipientId);
            // Refresh messages
            ref
                .read(groupMessagesProvider(widget.groupId).notifier)
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserNotifierProvider);

    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              // Xử lý khi nhấn vào nút thành viên nhóm
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Xử lý khi nhấn vào nút rời nhóm
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _showGroupActions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final messagesState =
                    ref.watch(groupMessagesProvider(widget.groupId));

                return messagesState.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(child: Text('Chưa có tin nhắn'));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return GroupMessageTile(
                          message: message,
                          onLongPress: () {
                            // Xử lý long press nếu cần
                          },
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                if (!_isInputFocused) ...[
                  // IconButton(
                  //   icon: Icon(Icons.add_circle, color: Colors.blue),
                  //   onPressed: () {},
                  // ),
                  // IconButton(
                  //   icon: Icon(Icons.camera_alt_outlined, color: Colors.blue),
                  //   onPressed: () {},
                  // ),
                  // IconButton(
                  //   icon: Icon(Icons.image_outlined, color: Colors.blue),
                  //   onPressed: () {},
                  // ),
                  // IconButton(
                  //   icon: Icon(Icons.mic_none_outlined, color: Colors.blue),
                  //   onPressed: () {},
                  // ),
                ],
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
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
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Aa',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions, color: Colors.blue),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                      _messageController.text.isEmpty
                          ? Icons.thumb_up
                          : Icons.send,
                      color: Colors.blue),
                  onPressed: () => _messageController.text.isEmpty
                      ? _sendMessage('👍')
                      : _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
