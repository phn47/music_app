import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed;
  final double pauseAfterRound;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
    this.speed = 30, // Giảm tốc độ từ 50 xuống 30 pixel/giây
    this.pauseAfterRound = 2.0, // Tăng thời gian dừng từ 1.5 lên 2.0 giây
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _textWidth = 0;
  double _containerWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateWidth();
    });
  }

  void _calculateWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    _textWidth = textPainter.width;
    _containerWidth = context.size?.width ?? 0;

    if (_textWidth > _containerWidth) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 500)); // Đợi trước khi bắt đầu
      if (!mounted) return;

      final double totalDistance = _textWidth - _containerWidth;
      final double duration = totalDistance / widget.speed;

      await _scrollController.animateTo(
        totalDistance,
        duration: Duration(seconds: duration.ceil()),
        curve: Curves.linear,
      );

      await Future.delayed(
          Duration(milliseconds: (widget.pauseAfterRound * 1000).toInt()));
      if (!mounted) return;

      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }
}
