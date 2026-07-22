import 'package:flutter/material.dart';
import '../theme/flex_theme.dart';
import '../models/rental_models.dart';
import '../utils/rental_utils.dart';

class RentalProgressCard extends StatelessWidget {
  final String tenantName;
  final String tenantPhoto;
  final String listingTitle;
  final double monthlyRent;
  final double timeProgress;
  final double paymentProgress;
  final int daysUntilNextPayment;
  final int lateDays;
  final PaymentStatus paymentStatus;
  final bool isActive;
  final VoidCallback? onTap;

  const RentalProgressCard({
    super.key,
    required this.tenantName,
    this.tenantPhoto = '',
    required this.listingTitle,
    required this.monthlyRent,
    required this.timeProgress,
    required this.paymentProgress,
    required this.daysUntilNextPayment,
    this.lateDays = 0,
    required this.paymentStatus,
    this.isActive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral800 : Colors.white;
    final statusColor = RentalUtils.paymentStatusColor(paymentStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: GeometricBackgroundPainter(
                  color: statusColor,
                  opacity: 0.05,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FlexSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(statusColor),
                  const SizedBox(height: 12),
                  _buildTenantInfo(),
                  const SizedBox(height: 12),
                  _buildProgressBar('Temps restant', timeProgress,
                    '${(timeProgress * 100).toInt()}% écoulé',
                    RentalUtils.daysLabel((monthlyRent / 30).toInt()),
                    FlexColors.primary500),
                  const SizedBox(height: 10),
                  _buildPaymentProgress(statusColor),
                  const SizedBox(height: 10),
                  _buildPaymentStatusBadge(statusColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : FlexColors.neutral400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(isActive ? 'Actif' : 'Inactif',
          style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF10B981) : FlexColors.neutral400)),
        const Spacer(),
        Text(RentalUtils.formatFCFA(monthlyRent) + '/mois',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
      ],
    );
  }

  Widget _buildTenantInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: FlexColors.primary100,
          backgroundImage: tenantPhoto.isNotEmpty ? NetworkImage(tenantPhoto) : null,
          child: tenantPhoto.isEmpty
              ? Text(tenantName.isNotEmpty ? tenantName[0].toUpperCase() : '?',
                  style: TextStyle(fontWeight: FontWeight.w600, color: FlexColors.primary500, fontSize: 14))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tenantName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(listingTitle, style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double progress, String leftText, String rightText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
            const Spacer(),
            Text(rightText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(leftText, style: TextStyle(fontSize: 10, color: FlexColors.neutral400)),
      ],
    );
  }

  Widget _buildPaymentProgress(Color statusColor) {
    final remaining = daysUntilNextPayment;
    return _buildProgressBar('Prochain paiement', paymentProgress,
      remaining <= 0 ? 'Échéance dépassée' : 'Plus que ${RentalUtils.daysLabel(remaining)}',
      RentalUtils.daysLabel(remaining),
      statusColor);
  }

  Widget _buildPaymentStatusBadge(Color statusColor) {
    final isProblem = paymentStatus == PaymentStatus.late || paymentStatus == PaymentStatus.unpaid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isProblem ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paymentStatus == PaymentStatus.onTime ? Icons.check_circle_rounded :
            paymentStatus == PaymentStatus.advance ? Icons.trending_up_rounded :
            paymentStatus == PaymentStatus.late ? Icons.warning_amber_rounded :
            paymentStatus == PaymentStatus.refunded ? Icons.replay_rounded :
            Icons.cancel_rounded,
            size: 14, color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            paymentStatus == PaymentStatus.onTime ? 'Paiement à temps' :
            paymentStatus == PaymentStatus.advance ? 'Paiement en avance' :
            paymentStatus == PaymentStatus.late ? 'En retard ($lateDays jours)' :
            paymentStatus == PaymentStatus.refunded ? 'Remboursé' :
            'Impayé',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusColor),
          ),
        ],
      ),
    );
  }
}
