class SendMessageRequest {
  final String senderId;
  final String receiverId;
  final String content;

  SendMessageRequest({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    };
  }
}
