import 'package:client/features/home/models/message_reaction_model.dart';

class Message1 {
  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentAt;
  final List<MessageReaction> reactions;

  Message1({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    this.reactions = const [],
  });

  factory Message1.fromJson(Map<String, dynamic> json) {
    return Message1(
      // Chuyển đổi id từ chuỗi sang int, mặc định 0 nếu không thành công
      id: int.tryParse(json['id'].toString()) ?? 0,

      // Kiểm tra senderId và receiverId có thể là null hoặc chuỗi rỗng
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',

      // Nếu content là null, mặc định là chuỗi rỗng
      content: json['content'] ?? '',

      // Xử lý trường sentAt, kiểm tra nếu giá trị không null thì parse thành DateTime
      sentAt: DateTime.tryParse(json['sent_at'] ?? '') ?? DateTime.now(),

      // Xử lý reactions, nếu không có thì mặc định là danh sách rỗng
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
      'content': content,
      'sent_at': sentAt.toIso8601String(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
    };
  }
}
