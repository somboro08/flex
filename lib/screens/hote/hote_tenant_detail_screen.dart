import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../utils/rental_utils.dart';

class HoteTenantDetailScreen extends StatelessWidget {
  final MonthlyRental rental;

  const HoteTenantDetailScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;
    final stats = rental.paymentStats;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(rental.voyageurNom, style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTenantHeader(cardColor, isDark),
            const SizedBox(height: 16),
            _buildRentalPeriodCard(cardColor, isDark),
            const SizedBox(height: 16),
            _buildPaymentStats(cardColor, isDark, stats),
            const SizedBox(height: 16),
            _buildProgressSection(cardColor, isDark),
            const SizedBox(height: 16),
            _buildPaymentHistory(cardColor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantHeader(Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.lg),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: FlexColors.primary100,
            child: Text(rental.voyageurNom[0].toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: FlexColors.primary500)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rental.voyageurNom, style: FlexTextStyles.h3.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
                const SizedBox(height: 4),
                Text(rental.voyageurTelephone, style: TextStyle(color: FlexColors.neutral500)),
                const SizedBox(height: 4),
                Text('${rental.listingTitle}, ${rental.listingVille}',
                  style: TextStyle(color: FlexColors.primary500, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: rental.isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : FlexColors.neutral200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(rental.isActive ? 'Actif' : 'Inactif',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: rental.isActive ? const Color(0xFF10B981) : FlexColors.neutral500)),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalPeriodCard(Color cardColor, bool isDark) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(color: FlexColors.primary500, opacity: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Période de location', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _DateColumn(label: 'Début', date: rental.startDate),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward_rounded, color: FlexColors.neutral400, size: 18),
                    ),
                    _DateColumn(label: 'Fin', date: rental.endDate ?? DateTime(2036, 1, 1)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Loyer mensuel', RentalUtils.formatFCFA(rental.monthlyRent), FlexColors.primary500),
                const SizedBox(height: 6),
                _buildInfoRow('Caution', RentalUtils.formatFCFA(rental.caution), FlexColors.neutral500),
                const SizedBox(height: 6),
                _buildInfoRow('Jour de facturation', 'Le ${rental.billingDay} de chaque mois', FlexColors.neutral500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStats(Color cardColor, bool isDark, Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.lg),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistiques de paiement', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniPill(label: 'À temps', count: stats['onTime']!, color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _MiniPill(label: 'Retard', count: stats['late']!, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _MiniPill(label: 'Avance', count: stats['advance']!, color: const Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              _MiniPill(label: 'Impayé', count: stats['unpaid']!, color: const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (stats['total'] ?? 1) > 0 ? (stats['onTime']! + stats['advance']!) / (stats['total'] ?? 1) : 0,
              minHeight: 6,
              backgroundColor: FlexColors.neutral200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 4),
          Text('${((stats['onTime']! + stats['advance']!) / ((stats['total'] ?? 1).clamp(1, 9999)) * 100).toInt()}% de paiements en règle',
            style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Color cardColor, bool isDark) {
    final currentStatus = rental.currentPaymentStatus;
    final statusColor = RentalUtils.paymentStatusColor(currentStatus);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(color: statusColor, opacity: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progression', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _ProgressRow(
                  label: 'Temps restant',
                  progress: rental.timeProgress,
                  leftText: '${(rental.timeProgress * 100).toInt()}% écoulé',
                  rightText: 'Reste ${RentalUtils.daysLabel(rental.remainingDays.toInt())}',
                  color: FlexColors.primary500,
                ),
                const SizedBox(height: 14),
                _ProgressRow(
                  label: 'Prochain paiement',
                  progress: rental.paymentCycleProgress,
                  leftText: rental.daysUntilNextPayment <= 0
                      ? 'Échéance dépassée'
                      : 'Plus que ${RentalUtils.daysLabel(rental.daysUntilNextPayment)}',
                  rightText: rental.daysUntilNextPayment <= 0
                      ? 'Exigible'
                      : RentalUtils.daysLabel(rental.daysUntilNextPayment),
                  color: statusColor,
                ),
                if (currentStatus == PaymentStatus.late || currentStatus == PaymentStatus.unpaid) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded, size: 16, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentStatus == PaymentStatus.late
                              ? 'Paiement en retard de ${rental.lateDays} jours. Relance recommandée.'
                              : 'Paiement impayé. Veuillez contacter le locataire.',
                            style: TextStyle(fontSize: 12, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.lg),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Historique des paiements', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${rental.payments.length} mois', style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
            ],
          ),
          const SizedBox(height: 12),
          ...rental.payments.reversed.map((p) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? FlexColors.neutral700 : FlexColors.neutral100)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: RentalUtils.paymentStatusColor(p.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    p.status == PaymentStatus.onTime ? Icons.check_circle_rounded :
                    p.status == PaymentStatus.advance ? Icons.trending_up_rounded :
                    p.status == PaymentStatus.late ? Icons.warning_amber_rounded :
                    p.status == PaymentStatus.refunded ? Icons.replay_rounded :
                    Icons.cancel_rounded,
                    size: 16, color: RentalUtils.paymentStatusColor(p.status),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(RentalUtils.monthLabel(
                        int.parse(p.periodLabel.split('-')[0]),
                        int.parse(p.periodLabel.split('-')[1]),
                      ), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      Text(RentalUtils.formatFCFA(p.amount),
                        style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: RentalUtils.paymentStatusColor(p.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(RentalUtils.paymentStatusLabel(p.status),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                      color: RentalUtils.paymentStatusColor(p.status))),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label : ', style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label; final DateTime date;
  const _DateColumn({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
        const SizedBox(height: 2),
        Text('${date.day} ${months[date.month - 1]} ${date.year}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label; final int count; final Color color;
  const _MiniPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label; final double progress; final String leftText; final String rightText; final Color color;
  const _ProgressRow({required this.label, required this.progress, required this.leftText, required this.rightText, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
            const Spacer(),
            Text(rightText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(leftText, style: TextStyle(fontSize: 10, color: FlexColors.neutral400)),
      ],
    );
  }
}
