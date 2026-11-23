import 'package:flutter/material.dart';
import '../../core/responsive/breakpoints.dart';
import '../../theme/flex_theme.dart';

class AdaptiveOverlay {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double desktopWidth = 560,
    bool isSidePanel = false,
    bool barrierDismissible = true,
  }) {
    if (context.isMobile) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: barrierDismissible,
        enableDrag: barrierDismissible,
        builder: (context) => child,
      );
    }

    if (isSidePanel && context.isDesktop) {
      return showGeneralDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: title ?? 'Overlay',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 16,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: SizedBox(
                width: desktopWidth,
                height: double.infinity,
                child: Column(
                  children: [
                    if (title != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                        ),
                        child: Row(
                          children: [
                            Text(title, style: FlexTextStyles.h3),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      );
    }

    // Default Desktop & Tablet presentation: Centered Modal Dialog
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: desktopWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
