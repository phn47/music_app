class GroupMember {
  final int id;
  final int groupId;
  final String userId;
  final bool isBanned;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    this.isBanned = false,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      isBanned: json['is_banned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'is_banned': isBanned,
    };
  }
}
