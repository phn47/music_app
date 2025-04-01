import 'package:client/features/home/providers/group_members_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupMembersList extends StatelessWidget {
  final int groupId;

  const GroupMembersList({
    required this.groupId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Consumer(
        builder: (context, ref, child) {
          return ref.watch(groupMembersProvider(groupId)).when(
                data: (members) => ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(member.userId[0].toUpperCase()),
                      ),
                      title: Text(member.userId),
                      subtitle: member.isBanned ? Text('Banned') : null,
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          if (!member.isBanned)
                            PopupMenuItem(
                              child: Text('Ban user'),
                              value: 'ban',
                            ),
                          if (member.isBanned)
                            PopupMenuItem(
                              child: Text('Unban user'),
                              value: 'unban',
                            ),
                          PopupMenuItem(
                            child: Text('Remove from group'),
                            value: 'remove',
                          ),
                        ],
                        onSelected: (value) {
                          // Handle actions
                          switch (value) {
                            case 'ban':
                              // Handle ban
                              break;
                            case 'unban':
                              // Handle unban
                              break;
                            case 'remove':
                              // Handle remove
                              break;
                          }
                        },
                      ),
                    );
                  },
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading members: $error'),
                ),
              );
        },
      ),
    );
  }
}
