import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';

/// Carte de présentation standard pour un overlay adaptatif.
///
/// Contrat : le widget fournit lui-même son fond (thème Flex), son padding
/// et son titre — `AdaptiveOverlay` reste transparent vis-à-vis du contenu
/// (sheet mobile transparent / dialog centré tablette-desktop / side panel).
class AdaptiveDialogContent extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;

  const AdaptiveDialogContent({
    super.key,
    this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 560),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(FlexSpacing.xl, FlexSpacing.lg, FlexSpacing.xl, FlexSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: FlexTextStyles.h3.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: FlexSpacing.lg),
                ],
                child,
                if (actions != null) ...[
                  const SizedBox(height: FlexSpacing.lg),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: actions!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}