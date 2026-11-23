import 'package:flutter/material.dart';
import 'breakpoints.dart';

class AdaptiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const AdaptiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth = 1440.0,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: context.responsiveHorizontalPadding,
    );

    Widget content = Padding(
      padding: effectivePadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (center) {
      return Align(
        alignment: Alignment.topCenter,
        child: content,
      );
    }

    return content;
  }
}
