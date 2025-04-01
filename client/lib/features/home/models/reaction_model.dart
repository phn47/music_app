enum ReactionType {
  heart,
  like,
  haha,
  wow,
  sad,
  angry,
}

class ReactionModel {
  final String id;
  final String commentId;
  final String userId;
  final ReactionType type;
  final DateTime createdAt;

  ReactionModel({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });
}
