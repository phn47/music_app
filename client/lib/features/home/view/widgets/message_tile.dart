import 'package:client/features/home/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget {
  final Message message;

  const MessageTile({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.senderId[0].toUpperCase()),
      ),
      title: Text(message.content),
      subtitle: Text(
        DateFormat('dd/MM/yyyy HH:mm').format(message.sentAt),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.reactions.isNotEmpty)
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: message.reactions
                    .map((reaction) => Text(reaction.emoji))
                    .toList(),
              ),
            ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show message options (edit, delete, react)
              showMessageOptions(context, message);
            },
          ),
        ],
      ),
    );
  }

  void showMessageOptions(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            onTap: () {
              // Handle edit
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
            onTap: () {
              // Handle delete
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_emotions),
            title: Text('React'),
            onTap: () {
              // Show emoji picker
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
