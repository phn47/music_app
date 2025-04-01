// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../widgets/chat_bubble.dart';
// import '../widgets/chat_input.dart';

// class ChatPage extends ConsumerWidget {
//   final String receiverId;

//   const ChatPage({super.key, required this.receiverId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             onPressed: () {
//               // Show options menu
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               padding: const EdgeInsets.all(8),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 return ChatBubble(
//                   message: messages[index],
//                   isMe: messages[index].senderId == currentUserId,
//                 );
//               },
//             ),
//           ),
//           const ChatInput(),
//         ],
//       ),
//     );
//   }
// }
