import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/providers/message_provider.dart';
import 'package:client/features/home/view/pages/group_chat_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:client/core/utils.dart';

class GroupMessagesTab extends ConsumerWidget {
  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tạo nhóm mới'),
          content: SingleChildScrollView(
            child: Container(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Tên nhóm',
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final pickedImage = await pickImage();
                      if (pickedImage != null) {
                        setState(() {
                          selectedImage = pickedImage;
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: selectedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chọn ảnh nhóm',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hỗ trợ định dạng PNG, JPG',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedImage != null) {
                  try {
                    await ref.read(messageRepositoryProvider).createGroup(
                          nameController.text,
                          selectedImage!,
                        );
                    Navigator.pop(context);
                    ref.refresh(groupChatsProvider);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Không thể tạo nhóm: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Vui lòng nhập tên nhóm và chọn ảnh')),
                  );
                }
              },
              child: Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupChats = ref.watch(groupChatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(groupChatsProvider.notifier).loadGroupChats();
        },
        child: groupChats.when(
          data: (groups) {
            if (groups.isEmpty) {
              return Center(
                child: Text('Chưa có nhóm nào'),
              );
            }

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final displayName = group.name.replaceAll('Nhóm ', '');

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
                      group.lastMessage != null && group.lastMessage!.isNotEmpty
                          ? Text(
                              group.lastMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                  onTap: () {
                    ref
                        .read(messageRepositoryProvider)
                        .getGroupMessages(group.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatPage(
                          groupId: group.id,
                          groupName: displayName,
                          creatorId: group.creatorId,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context, ref),
        child: Icon(Icons.group_add),
      ),
    );
  }
}
