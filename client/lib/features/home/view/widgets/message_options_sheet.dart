import 'package:client/features/home/models/message_model.dart';
import 'package:flutter/material.dart';

class MessageOptionsSheet extends StatelessWidget {
  final Message message;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReact;

  const MessageOptionsSheet({
    required this.message,
    required this.onEdit,
    required this.onDelete,
    required this.onReact,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Message'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete Message'),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          ListTile(
            leading: Icon(Icons.emoji_emotions),
            title: Text('Add Reaction'),
            onTap: () {
              Navigator.pop(context);
              onReact();
            },
          ),
        ],
      ),
    );
  }
}
