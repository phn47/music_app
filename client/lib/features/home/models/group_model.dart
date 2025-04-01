import 'package:client/features/home/models/group_member_model.dart';

class Group {
  final int id;
  final String name;
  final String thumbnailUrl;
  final String creatorId;
  final List<GroupMember> members;

  Group({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.creatorId,
    this.members = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      thumbnailUrl: json['thumbnail_url'],
      creatorId: json['creator_id'],
      members: (json['members'] as List?)
              ?.map((e) => GroupMember.fromJson(e))
              .toList() ??
          [],
    );
  }
}
