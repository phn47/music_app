// import 'package:client/core/models/message_model.dart';
import 'package:client/features/home/models/message_model.dart';

class ChatConversation {
  final Message otherUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatConversation({
    required this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      otherUser: Message.fromJson(json['other_user']),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
    );
  }
}

// class ChatConversation {
//   final UserModel id;
//   final String? name;
//   final String? imageUrl;

//   ChatConversation({
//     required this.id,
//     this.name,
//     this.imageUrl,
//   });

//   factory ChatConversation.fromJson(Map<String, dynamic> json) {
//     return ChatConversation(
//       id: UserModel.fromJson(json['other_user']),
//       name: json['last_message'],
//       imageUrl: json['last_message_time'] ?? '',
//       // ? DateTime.parse(json['last_message_time'])
//       // : null,
//     );
//   }
// }
