import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onReactionSelected;

  const ReactionPicker({
    required this.onReactionSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 5,
        children: ['😀', '😍', '😂', '😭', '😡', '👍', '👎', '❤️', '😮', '🎉']
            .map((emoji) => GestureDetector(
                  onTap: () {
                    onReactionSelected(emoji);
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
