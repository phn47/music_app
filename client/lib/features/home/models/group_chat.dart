class GroupChat {
  final int id;
  final String name;
  final String? thumbnailUrl;
  final String creatorId;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  GroupChat({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    required this.creatorId,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['id'],
      name: json['name'],
      thumbnailUrl: json['thumbnail_url'],
      creatorId: json['creator_id'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_url': thumbnailUrl,
      'creator_id': creatorId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
    };
  }
}
