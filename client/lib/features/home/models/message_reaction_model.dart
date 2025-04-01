class MessageReaction {
  final int id;
  final int messageId;
  final String userId;
  final int groupId;
  final String emoji;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.groupId,
    required this.emoji,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      id: json['id'],
      messageId: json['message_id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'group_id': groupId,
      'emoji': emoji,
    };
  }
}
