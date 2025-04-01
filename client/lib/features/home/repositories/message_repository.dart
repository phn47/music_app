import 'dart:ffi';
import 'dart:io';

import 'package:client/core/models/user_model.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/chat_conversation.dart';
import 'package:client/features/home/models/group_chat.dart';
import 'package:client/features/home/models/group_messages.dart';
import 'package:client/features/home/models/message_model.dart';
import 'package:client/features/home/models/group_member_model.dart';
import 'package:client/features/home/models/message_reaction_model.dart';
import 'package:client/features/home/models/send_message_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageRepository {
  final Dio _dio;
  final Ref _ref;

  const MessageRepository._({
    required Dio dio,
    required Ref ref,
  })  : _dio = dio,
        _ref = ref;

  factory MessageRepository({required Dio dio, required Ref ref}) {
    return MessageRepository._(dio: dio, ref: ref);
  }

  String? _getToken() {
    final currentUser = _ref.read(currentUserNotifierProvider);
    return currentUser?.token;
  }

  Options _getOptions() {
    final token = _getToken();
    if (token == null) throw Exception('User not authenticated');

    return Options(
      headers: {
        'x-auth-token': token,
      },
    );
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '/songs/users/search',
        queryParameters: {'query': query},
        options: _getOptions(),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => UserModel.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Search users error: ${e.toString()}');
      throw Exception('Error searching users: ${e.toString()}');
    }
  }

  Future<List<Message>> getGroupMessages(int groupId) async {
    try {
      final currentUser = _ref.read(currentUserNotifierProvider);
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _dio.get(
        '/songs/groups/$groupId/messages',
        options: _getOptions(),
      );

      // In dữ liệu trả về từ API
      print('Response Data: ${response.data}'); // In ra dữ liệu trả về

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Kiểm tra lại dữ liệu nhận được
        print('Parsed Messages: $data'); // In ra dữ liệu sau khi parse
        return data.map((json) {
          // Chuyển đổi id từ int thành String
          json['id'] = json['id'].toString();
          return Message.fromJson(
              json); // Gọi phương thức fromJson sau khi chuyển đổi id
        }).toList();
      }

      throw DioException(
        requestOptions: RequestOptions(path: '/songs/groups/$groupId/messages'),
        error: 'Failed to fetch messages',
        response: response,
      );
    } catch (e) {
      // In ra lỗi chi tiết để hỗ trợ gỡ lỗi
      print('Error getting group messages: ${e.toString()}');
      throw Exception('Error getting group messages: ${e.toString()}');
    }
  }

  Future<Message> sendGroupMessage(int groupId, String content) async {
    try {
      final currentUser = _ref.read(currentUserNotifierProvider);
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _dio.post(
        '/songs/groups/messages',
        data: {'group_id': groupId, 'content': content},
        options: _getOptions(),
      );
      return Message.fromJson(response.data);
    } catch (e) {
      throw Exception('Error sending group message: ${e.toString()}');
    }
  }

  Future<void> sendDirectMessage(String receiverId, String content) async {
    try {
      final currentUser = _ref.read(currentUserNotifierProvider);
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Gửi yêu cầu tin nhắn
      final request = SendMessageRequest(
        senderId: currentUser.id, // Lấy senderId từ currentUser
        receiverId: receiverId,
        content: content,
      );

      final response = await _dio.post(
        '/songs/message/send',
        data: request.toJson(),
        options: _getOptions(),
      );

      // Nếu cần thiết, có thể làm thêm các hành động sau khi gửi thành công
      print('Message sent: ${response.data}');
    } catch (e) {
      throw Exception('Error sending message: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(String messageId, String userId) async {
    try {
      await _dio
          .delete('/songs/messagexoa/$messageId', data: {'user_id': userId});
    } catch (e) {
      throw Exception('Error deleting message: ${e.toString()}');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _dio.post('/songs/messagechinhsua/$messageId',
          data: {'new_content': newContent});
    } catch (e) {
      throw Exception('Error editing message: ${e.toString()}');
    }
  }

  // Future<void> reactToMessage(String messageId, String emoji) async {
  //   try {
  //     await _dio
  //         .post('/songs/messages/$messageId/reactions', data: {'emoji': emoji});
  //   } catch (e) {
  //     throw Exception('Error adding reaction: ${e.toString()}');
  //   }
  // }

  Future<List<Message>> getDirectMessages(String receiverId) async {
    try {
      // Gửi POST request với receiver_id và token để xác định user1
      final response = await _dio.post(
        '/songs/message/conversation',
        data: {'user2_id': receiverId}, // Truyền user2_id vào body
        options: _getOptions(), // Token xác thực từ _getOptions()
      );

      // Trích xuất danh sách tin nhắn từ response
      final messages = (response.data['conversation'] as List)
          .map((message) => Message.fromJson(message))
          .toList();

      return messages;
    } catch (e) {
      print('Error getting direct messages: $e');
      throw Exception('Không thể tải danh sách tin nhắn');
    }
  }

  Future<void> leaveGroup(int groupId) async {
    try {
      await _dio.post('/songs/groups/$groupId/leave');
    } catch (e) {
      throw Exception('Error leaving group: ${e.toString()}');
    }
  }

  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    try {
      final response = await _dio.get('/songs/groups/$groupId/members');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GroupMember.fromJson(json)).toList();
      }

      throw 'Failed to fetch group members';
    } catch (e) {
      throw 'Error getting group members: $e';
    }
  }

  Future<void> sendMessage(SendMessageRequest request) async {
    try {
      await _dio.post('/songs/message/send', data: request.toJson());
    } catch (e) {
      throw Exception('Error sending message: ${e.toString()}');
    }
  }

  Future<void> addReaction({
    required int messageId,
    required String emoji,
    required String token,
  }) async {
    try {
      // Gửi yêu cầu POST tới API
      final response = await _dio.post(
        'songs/messages/react',
        data: {
          'message_id': messageId, // ID của tin nhắn
          'emoji': emoji, // Emoji cảm xúc
        },
        options: Options(
          headers: {
            'x-auth-token': token, // Token để xác thực người dùng
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Reaction added successfully");
      } else {
        throw Exception("Failed to add reaction: ${response.data['detail']}");
      }
    } catch (e) {
      // Xử lý lỗi trong quá trình gọi API
      throw Exception("Error adding reaction: $e");
    }
  }

  Future<Map<String, dynamic>> createDirectChat(String receiverId) async {
    try {
      final response = await _dio.post(
        '/songs/messages/create-direct-chat',
        data: {'receiver_id': receiverId},
        options: _getOptions(),
      );
      return response.data;
    } catch (e) {
      print('Error creating direct chat: $e');
      throw Exception('Không thể tạo cuộc trò chuyện');
    }
  }

  Future<List<ChatConversation>> getDirectChats() async {
    try {
      final currentUser = _ref.read(currentUserNotifierProvider);
      if (currentUser == null) throw Exception('Chưa đăng nhập');

      final response = await _dio.post(
        '/songs/user/messages/receivers1',
        options: _getOptions(),
      );

      if (response.data is Map<String, dynamic>) {
        final receivers = response.data['receivers'] as List<dynamic>;

        return receivers
            .map((receiver) => ChatConversation(
                  otherUser: Message(
                    id: receiver['receiver_id'].toString(),
                    receiverId: receiver['receiver_id'],
                    receiver_name: receiver['receiver_name'], // Lấy tên từ API
                    senderId: currentUser.id, // ID của user hiện tại
                    content: '', // Nội dung tin nhắn cuối (cập nhật nếu cần)
                    reactions: [], // Reactions (cập nhật nếu API cung cấp)
                    sentAt:
                        DateTime.now(), // Thời gian (cập nhật nếu có từ API)
                  ),
                  lastMessage: null, // Tin nhắn cuối cùng (cập nhật nếu có)
                  lastMessageTime:
                      null, // Thời gian tin nhắn cu���i (cập nhật nếu có)
                ))
            .toList();
      } else {
        throw Exception('Dữ liệu trả về không hợp lệ');
      }
    } catch (e) {
      print('Error getting direct chats: $e');
      throw Exception('Không thể tải danh sách cuộc trò chuyện');
    }
  }

  Future<List<GroupChat>> getGroupChats() async {
    try {
      final response = await _dio.post(
        '/songs/user/groups/membership',
        options: _getOptions(),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final groupsData = data['groups'] as List<dynamic>;

        // Map dữ liệu từ API vào model GroupChat
        return groupsData.map((groupData) {
          return GroupChat(
            id: groupData['id'],
            name: groupData['name'],
            thumbnailUrl: groupData['thumbnail_url'],
            creatorId: groupData['creator_id'],
          );
        }).toList();
      } else {
        throw Exception('Dữ liệu trả về không hợp lệ');
      }
    } catch (e) {
      print('Error getting group chats: $e');
      throw Exception('Không thể tải danh sách nhóm');
    }
  }

  // Tạo nhóm mới
  Future<GroupChat> createGroup(String groupName, File thumbnailFile) async {
    try {
      // Tạo form data để gửi file
      final formData = FormData.fromMap({
        'group_name': groupName,
        'thumbnail': await MultipartFile.fromFile(
          thumbnailFile.path,
          filename: 'thumbnail.jpg',
        ),
      });

      final response = await _dio.post(
        '/songs/groups',
        data: formData,
        options: _getOptions(),
      );

      return GroupChat(
          id: response.data['group_id'] ?? 0,
          name: response.data['group_name'] ?? groupName,
          thumbnailUrl: response.data['thumbnail_url'] ?? '',
          creatorId: response.data['creator_id'] ?? '',
          lastMessage: null,
          lastMessageTime: null);
    } catch (e) {
      throw Exception('Không thể tạo nhóm: ${e.toString()}');
    }
  }

  // Thêm thành viên vào nhóm
  Future<void> addMemberToGroup(int groupId, String userId) async {
    try {
      await _dio.post(
        '/songs/groups/add-member',
        data: {'group_id': groupId, 'user_id': userId},
        options: _getOptions(),
      );
    } catch (e) {
      throw Exception('Không thể thêm thành viên: ${e.toString()}');
    }
  }

  // Cấm tất cả thành viên
  Future<void> banAllMembers(int groupId) async {
    try {
      await _dio.post(
        '/songs/groups/ban-all',
        data: {'group_id': groupId},
        options: _getOptions(),
      );
    } catch (e) {
      throw Exception('Không thể cấm thành viên: ${e.toString()}');
    }
  }

  // Gỡ cấm tất cả thành viên
  Future<void> unbanAllMembers(int groupId) async {
    try {
      await _dio.post(
        '/songs/groups/unban-all',
        data: {'group_id': groupId},
        options: _getOptions(),
      );
    } catch (e) {
      throw Exception('Không thể gỡ cấm thành viên: ${e.toString()}');
    }
  }

  // Thêm phương thức để lấy reactions
  Future<List<MessageReaction>> getReactions(int messageId) async {
    try {
      final response = await _dio.get(
        '/songs/messages/reactions',
        queryParameters: {'message_id': messageId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> reactions = response.data['reactions'];
        return reactions
            .map((reaction) => MessageReaction.fromJson(reaction))
            .toList();
      }
      throw 'Failed to get reactions';
    } catch (e) {
      throw e.toString();
    }
  }

  // Thêm phương thức để thả reaction
  Future<void> reactToMessage({
    required int messageId, // Chuyển messageId thành String
    required String emoji,
    required String token,
    required String recipientId,
  }) async {
    try {
      // Gửi yêu cầu POST tới API
      final response = await _dio.post(
        '/songs/messages/react3',
        data: {
          'message_id': messageId, // ID của tin nhắn (dạng chuỗi)
          'emoji': emoji, // Emoji cảm xúc
          'recipient_id': recipientId
        },
        options: Options(
          headers: {
            'x-auth-token': token, // Token để xác thực người dùng
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Reaction added successfully");
      } else {
        throw Exception("Failed to add reaction: ${response.data['detail']}");
      }
    } catch (e) {
      // Xử lý lỗi trong quá trình gọi API
      throw Exception("Error adding reaction: $e");
    }
  }

  // Thêm phương thức để thả reaction
  // Future<void> reactToMessage({
  //   required int messageId,
  //   required String emoji,
  //   required String token,
  // }) async {
  //   try {
  //     // Gửi yêu cầu POST tới API
  //     final response = await _dio.post(
  //       '/songs/messages/react',
  //       data: {
  //         'message_id': messageId, // ID của tin nhắn
  //         'emoji': emoji, // Emoji cảm xúc
  //       },
  //       options: Options(
  //         headers: {
  //           'x-auth-token': token, // Token để xác thực người dùng
  //         },
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       print("Reaction added successfully");
  //     } else {
  //       throw Exception("Failed to add reaction: ${response.data['detail']}");
  //     }
  //   } catch (e) {
  //     // Xử lý lỗi trong quá trình gọi API
  //     throw Exception("Error adding reaction: $e");
  //   }
  // }
}
