import 'package:client/features/home/models/message_reaction_model.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String receiver_name;
  final String content;
  final DateTime sentAt;
  final List<MessageReaction> reactions;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.receiver_name,
    required this.content,
    required this.sentAt,
    this.reactions = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      // Chuyển đổi kiểu String sang int nếu cần
      id: json['id'] ?? '',
      senderId:
          json['sender_id'] ?? '', // Trường hợp null, gán giá trị mặc định
      receiverId: json['receiver_id'] ?? '',
      receiver_name: json['receiver_name'] ?? '',
      content: json['content'] ?? '', // Trường hợp null, gán giá trị mặc định
      sentAt: DateTime.parse(json['sent_at'] ??
          DateTime.now()
              .toIso8601String()), // Trường hợp null, dùng thời gian hiện tại
      // Xử lý trường reactions, nếu không có dữ liệu thì mặc định là danh sách rỗng
      reactions: (json['reactions'] as List?)
              ?.map((e) => MessageReaction.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'receiver_name': receiver_name,
      'content': content,
      'sent_at': sentAt.toIso8601String(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
    };
  }
}
