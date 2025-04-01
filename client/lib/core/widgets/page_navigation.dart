import 'package:flutter/material.dart';

class PageNavigation {
  static void navigateWithSlide(
    BuildContext context,
    Widget page, {
    bool replace = false,
    bool clearStack = false,
  }) {
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (clearStack) {
      Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
    } else if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  static void navigateToChild(
    BuildContext context,
    Widget page,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        maintainState: true,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 0.05);
          var end = Offset.zero;
          var curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            ),
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  static void navigateToModal(
    BuildContext context,
    Widget page,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        maintainState: true,
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeOutBack;

          var scaleAnimation = animation.drive(
            Tween(begin: 0.95, end: 1.0).chain(
              CurveTween(curve: curve),
            ),
          );

          var fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}
