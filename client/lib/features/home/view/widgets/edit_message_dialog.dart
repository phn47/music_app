import 'package:flutter/material.dart';

class EditMessageDialog extends StatefulWidget {
  final String initialText;

  const EditMessageDialog({
    required this.initialText,
    Key? key,
  }) : super(key: key);

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Message'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter new message',
        ),
        maxLines: null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
