import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class WaveDotsAnimation extends StatefulWidget {
  const WaveDotsAnimation({super.key});

  @override
  State<WaveDotsAnimation> createState() => _WaveDotsAnimationState();
}

class _WaveDotsAnimationState extends State<WaveDotsAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 300 + (index * 40)),
        vsync: this,
      );

      // Bắt đầu animation ngay lập tức với độ trễ khác nhau
      controller.forward();
      controller.repeat(reverse: true);

      return controller;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: 4 + (_controllers[index].value * 12),
              decoration: BoxDecoration(
                color: Pallete.whiteColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Pallete.whiteColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
