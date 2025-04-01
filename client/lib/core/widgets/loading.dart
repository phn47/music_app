import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _timer = Timer(const Duration(seconds: 2), () {
      _fadeOutAndNavigate();
    });
  }

  void _fadeOutAndNavigate() {
    setState(() {
      _opacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 400),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    '',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color.fromRGBO(251, 109, 169, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(210, 106, 150, 1),
                  ),
                  strokeWidth: 6.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
