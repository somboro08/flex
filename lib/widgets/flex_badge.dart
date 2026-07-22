import 'package:flutter/material.dart';
import '../theme/flex_theme.dart';
import '../models/models.dart';

class CertificationBadge extends StatelessWidget {
  final CertificationStatus status;
  const CertificationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case CertificationStatus.certified:
        bg = FlexColors.certified;
        fg = Colors.white;
        icon = Icons.verified_rounded;
        label = 'Flex Certifié';
        break;
      case CertificationStatus.pending:
        bg = FlexColors.warning;
        fg = Colors.white;
        icon = Icons.hourglass_top_rounded;
        label = 'En attente';
        break;
      case CertificationStatus.rejected:
        bg = FlexColors.error;
        fg = Colors.white;
        icon = Icons.cancel_rounded;
        label = 'Non certifié';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FlexRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: FlexTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FlexBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const FlexBadge({super.key, required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? FlexColors.primary500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(FlexRadius.full),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: FlexTextStyles.caption.copyWith(
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
