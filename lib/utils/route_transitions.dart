import 'package:flutter/material.dart';

class FlexPageRoute<T> extends PageRouteBuilder<T> {
  FlexPageRoute({required Widget page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.06);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation.drive(fadeTween), child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

void pushFlex(BuildContext context, Widget page) {
  Navigator.push(context, FlexPageRoute(page: page));
}
