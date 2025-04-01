class GroupMessage {
  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentAt;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
  });

  // Phương thức từ JSON
  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: int.parse(json['id'].toString()), // Chuyển từ String sang int
      senderId: json['sender_id'] ?? '', // Chuyển từ String sang int
      receiverId: json['receiver_id'] ?? '',
      // Chuyển từ String sang int
      content: json['content'],
      sentAt: DateTime.parse(json['sent_at']), // Chuyển chuỗi sang DateTime
    );
  }

  // Phương thức để chuyển sang Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

// import 'package:client/features/home/models/message_reaction_model.dart';

// class GroupMessage {
//   final int id; // Thay đổi kiểu id từ String sang int
//   final String senderId;
//   final String receiverId;
//   final String receiver_name;
//   final String content;
//   final DateTime sentAt;
//   final List<MessageReaction> reactions;

//   GroupMessage({
//     required this.id,
//     required this.senderId,
//     required this.receiverId,
//     required this.receiver_name,
//     required this.content,
//     required this.sentAt,
//     this.reactions = const [],
//   });

//   factory GroupMessage.fromJson(Map<String, dynamic> json) {
//     return GroupMessage(
//       id: json['id'] != null
//           ? int.tryParse(json['id'].toString()) ?? 0
//           : 0, // Chuyển đổi id sang int
//       senderId: json['sender_id'] ?? '',
//       receiverId: json['receiver_id'] ?? '',
//       receiver_name: json['receiver_name'] ?? '',
//       content: json['content'] ?? '',
//       sentAt: DateTime.parse(json['sent_at'] ??
//           DateTime.now()
//               .toIso8601String()), // Sử dụng thời gian hiện tại nếu null
//       reactions: (json['reactions'] as List?)
//               ?.map((e) => MessageReaction.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id, // id bây giờ là kiểu int
//       'sender_id': senderId,
//       'receiver_id': receiverId,
//       'receiver_name': receiver_name,
//       'content': content,
//       'sent_at': sentAt.toIso8601String(),
//       'reactions': reactions.map((e) => e.toJson()).toList(),
//     };
//   }
// }
