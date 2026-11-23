import 'package:flutter/material.dart';
import '../../core/responsive/breakpoints.dart';

class AdaptiveGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final int largeDesktopCrossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AdaptiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 3,
    this.largeDesktopCrossAxisCount = 4,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 0.85,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  int getCrossAxisCount(BuildContext context) {
    if (context.isLargeDesktop) return largeDesktopCrossAxisCount;
    if (context.isDesktop) return desktopCrossAxisCount;
    if (context.isTablet) return tabletCrossAxisCount;
    return mobileCrossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    final columns = getCrossAxisCount(context);

    if (columns == 1) {
      return ListView.separated(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: mainAxisSpacing),
        itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      );
    }

    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
    );
  }
}
