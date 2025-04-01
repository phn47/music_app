import 'package:client/features/home/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/comment_provider.dart';
import 'comment_tile.dart';
import 'package:flutter/services.dart';

class CommentSection extends ConsumerStatefulWidget {
  final String songId;
  final String userId;

  const CommentSection({
    Key? key,
    required this.songId,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentNotifierProvider.notifier).loadComments(widget.songId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildCommentList(),
        ),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _postComment(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    filled: false,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                  onPressed: _postComment,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await ref
          .read(commentNotifierProvider.notifier)
          .addComment(content, widget.userId);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi bình luận: $e')),
        );
      }
    }
  }

  void _showReactionMenu(
      BuildContext context, CommentModel comment, Offset tapPosition) {
    final size = MediaQuery.of(context).size;
    final isMyComment = comment.userId == widget.userId;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        size.width - tapPosition.dx,
        size.height - tapPosition.dy,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReactionIcon('❤️', () => _onReaction(comment, 'heart')),
              _buildReactionIcon('👍', () => _onReaction(comment, 'like')),
              _buildReactionIcon('😆', () => _onReaction(comment, 'haha')),
              _buildReactionIcon('😮', () => _onReaction(comment, 'wow')),
              _buildReactionIcon('😢', () => _onReaction(comment, 'sad')),
              _buildReactionIcon('😠', () => _onReaction(comment, 'angry')),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'copy',
          child: const Row(
            children: [
              Icon(Icons.copy, size: 20),
              SizedBox(width: 8),
              Text('Sao chép'),
            ],
          ),
        ),
        if (isMyComment) ...[
          PopupMenuItem<String>(
            value: 'edit',
            child: const Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Chỉnh sửa'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: const Row(
              children: [
                Icon(Icons.delete, size: 20),
                SizedBox(width: 8),
                Text('Xóa'),
              ],
            ),
          ),
        ],
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'copy':
          _copyComment(comment.content);
          break;
        case 'edit':
          _showEditDialog(comment);
          break;
        case 'delete':
          _showDeleteDialog(comment);
          break;
      }
    });
  }

  Widget _buildReactionIcon(String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  void _onReaction(CommentModel comment, String reactionType) {
    // TODO: Implement reaction logic
    print('Reacted with $reactionType to comment: ${comment.id}');
  }

  void _copyComment(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép bình luận')),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final RenderBox button = context.findRenderObject() as RenderBox;
          final Offset position = button.localToGlobal(Offset.zero);

          _showReactionMenu(
            context,
            comment,
            Offset(position.dx, position.dy + button.size.height),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900], // Màu nền tối cho dark theme
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User', // Tên người dùng
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 48), // Để lại khoảng trống bên phải
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Future<void> _showEditDialog(CommentModel comment) async {
    final controller = TextEditingController(text: comment.content);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa bình luận'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung mới',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref
                    .read(commentNotifierProvider.notifier)
                    .editComment(comment.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(CommentModel comment) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bình luận'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(commentNotifierProvider.notifier)
                  .deleteComment(comment.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    return ref.watch(commentNotifierProvider).when(
          data: (comments) {
            if (comments.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có bình luận nào.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentTile(
                  comment: comment,
                  showActions: comment.userId == widget.userId,
                  onEdit: () => _showEditDialog(comment),
                  onDelete: () => _showDeleteDialog(comment),
                  userName: '',
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Lỗi: $error',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
  }
}
