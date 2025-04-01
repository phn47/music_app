import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/messages_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.message),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MessagesPage()),
        );
      },
    );
  }
}
