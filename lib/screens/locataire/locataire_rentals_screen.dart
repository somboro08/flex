import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../utils/rental_utils.dart';
import '../../widgets/rental_progress_widget.dart';
import 'advance_payment_screen.dart';
import 'refund_request_screen.dart';
import 'renew_booking_screen.dart';

class LocataireRentalsScreen extends StatefulWidget {
  const LocataireRentalsScreen({super.key});

  @override
  State<LocataireRentalsScreen> createState() => _LocataireRentalsScreenState();
}

class _LocataireRentalsScreenState extends State<LocataireRentalsScreen> {
  final List<MonthlyRental> _myRentals = [
    MonthlyRental(
      id: 'r1', listingId: 'l1', listingTitle: 'Villa Ouidah', listingVille: 'Ouidah',
      listingPhoto: '', hoteId: 'h1', hoteNom: 'Jean Hôte',
      voyageurId: 'v1', voyageurNom: 'Moi',
      voyageurTelephone: '+229 97 11 22 33',
      startDate: DateTime(2026, 1, 15), monthlyRent: 150000, billingDay: 5,
      payments: [
        RentalPayment(id: 'p1', rentalId: 'r1', periodLabel: '2026-01', amount: 150000, dueDate: DateTime(2026, 1, 5), paidAt: DateTime(2026, 1, 3), status: PaymentStatus.advance),
        RentalPayment(id: 'p2', rentalId: 'r1', periodLabel: '2026-02', amount: 150000, dueDate: DateTime(2026, 2, 5), paidAt: DateTime(2026, 2, 4), status: PaymentStatus.onTime),
        RentalPayment(id: 'p3', rentalId: 'r1', periodLabel: '2026-03', amount: 150000, dueDate: DateTime(2026, 3, 5), paidAt: DateTime(2026, 3, 3), status: PaymentStatus.advance),
        RentalPayment(id: 'p4', rentalId: 'r1', periodLabel: '2026-04', amount: 150000, dueDate: DateTime(2026, 4, 5), paidAt: DateTime(2026, 4, 2), status: PaymentStatus.advance),
        RentalPayment(id: 'p5', rentalId: 'r1', periodLabel: '2026-05', amount: 150000, dueDate: DateTime(2026, 5, 5), paidAt: DateTime(2026, 5, 1), status: PaymentStatus.advance),
        RentalPayment(id: 'p6', rentalId: 'r1', periodLabel: '2026-06', amount: 150000, dueDate: DateTime(2026, 6, 5), paidAt: DateTime(2026, 5, 28), status: PaymentStatus.advance),
        RentalPayment(id: 'p7', rentalId: 'r1', periodLabel: '2026-07', amount: 150000, dueDate: DateTime(2026, 7, 5), status: PaymentStatus.unpaid),
      ],
      createdAt: DateTime(2026, 1, 10),
    ),
    MonthlyRental(
      id: 'r4', listingId: 'l3', listingTitle: 'Chambre Parakou', listingVille: 'Parakou',
      listingPhoto: '', hoteId: 'h2', hoteNom: 'Mme Akobi',
      voyageurId: 'v1', voyageurNom: 'Moi',
      voyageurTelephone: '+229 97 11 22 33',
      startDate: DateTime(2026, 2, 10), endDate: DateTime(2026, 8, 10), monthlyRent: 50000, billingDay: 10,
      payments: [
        RentalPayment(id: 'p22', rentalId: 'r4', periodLabel: '2026-02', amount: 50000, dueDate: DateTime(2026, 2, 10), paidAt: DateTime(2026, 2, 8), status: PaymentStatus.onTime),
        RentalPayment(id: 'p23', rentalId: 'r4', periodLabel: '2026-03', amount: 50000, dueDate: DateTime(2026, 3, 10), paidAt: DateTime(2026, 3, 10), status: PaymentStatus.onTime),
        RentalPayment(id: 'p24', rentalId: 'r4', periodLabel: '2026-04', amount: 50000, dueDate: DateTime(2026, 4, 10), paidAt: DateTime(2026, 4, 5), status: PaymentStatus.advance),
        RentalPayment(id: 'p25', rentalId: 'r4', periodLabel: '2026-05', amount: 50000, dueDate: DateTime(2026, 5, 10), paidAt: DateTime(2026, 5, 25), status: PaymentStatus.late),
        RentalPayment(id: 'p26', rentalId: 'r4', periodLabel: '2026-06', amount: 50000, dueDate: DateTime(2026, 6, 10), paidAt: DateTime(2026, 6, 9), status: PaymentStatus.onTime),
        RentalPayment(id: 'p27', rentalId: 'r4', periodLabel: '2026-07', amount: 50000, dueDate: DateTime(2026, 7, 10), status: PaymentStatus.unpaid),
      ],
      createdAt: DateTime(2026, 2, 5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalMonthly = _myRentals.where((r) => r.isActive).fold(0.0, (s, r) => s + r.monthlyRent);

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Mes locations', style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSummary(isDark, totalMonthly),
            const SizedBox(height: 20),
            ..._myRentals.map((r) => RentalProgressCard(
              tenantName: r.hoteNom,
              listingTitle: '${r.listingTitle} - ${r.listingVille}',
              monthlyRent: r.monthlyRent,
              timeProgress: r.timeProgress,
              paymentProgress: r.paymentCycleProgress,
              daysUntilNextPayment: r.daysUntilNextPayment,
              lateDays: r.lateDays,
              paymentStatus: r.currentPaymentStatus,
              isActive: r.isActive,
              onTap: () => _showRentalActions(context, r),
            )),
            const SizedBox(height: 20),
            _buildQuickActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary(bool isDark, double totalMonthly) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        gradient: LinearGradient(
          colors: isDark
              ? [FlexColors.neutral800, FlexColors.neutral900]
              : [Colors.white, FlexColors.neutral50],
        ),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(color: FlexColors.primary500, opacity: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total loyers/mois', style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
                      const SizedBox(height: 4),
                      Text(RentalUtils.formatFCFA(totalMonthly),
                        style: FlexTextStyles.h2.copyWith(color: FlexColors.primary500)),
                      const SizedBox(height: 2),
                      Text('${_myRentals.where((r) => r.isActive).length} location(s) active(s)',
                        style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                    ],
                  ),
                ),
                Icon(Icons.home_rounded, size: 40, color: FlexColors.primary500.withValues(alpha: 0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions rapides', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _ActionButton(
              icon: Icons.payments_rounded, label: 'Payer en avance',
              color: const Color(0xFF3B82F6),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancePaymentScreen())),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.replay_rounded, label: 'Renouveler',
              color: const Color(0xFF10B981),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RenewBookingScreen())),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.receipt_long_rounded, label: 'Remboursement',
              color: const Color(0xFF8B5CF6),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RefundRequestScreen())),
            )),
          ],
        ),
      ],
    );
  }

  void _showRentalActions(BuildContext context, MonthlyRental rental) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(FlexSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: FlexColors.neutral300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(rental.listingTitle, style: FlexTextStyles.h3),
            Text(rental.listingVille, style: TextStyle(color: FlexColors.neutral500)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.payments_rounded, color: Color(0xFF3B82F6)),
              title: const Text('Payer en avance'),
              subtitle: const Text('Effectuer un paiement anticipé'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => AdvancePaymentScreen(rental: rental))); },
            ),
            ListTile(
              leading: const Icon(Icons.replay_rounded, color: Color(0xFF10B981)),
              title: const Text('Renouveler le bail'),
              subtitle: const Text('Prolonger votre période de location'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => RenewBookingScreen(rental: rental))); },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF8B5CF6)),
              title: const Text('Demander un remboursement'),
              subtitle: const Text('Soumettre une demande de remboursement'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => RefundRequestScreen(rental: rental))); },
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded, color: FlexColors.primary500),
              title: const Text('Voir le détail'),
              subtitle: const Text('Toutes les informations de votre location'),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => _RentalDetailScreen(rental: rental))); },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
          ],
        ),
      ),
    );
  }
}

// Detail screen for a single rental (tenant's perspective)
class _RentalDetailScreen extends StatelessWidget {
  final MonthlyRental rental;
  const _RentalDetailScreen({required this.rental});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(rental.listingTitle, style: FlexTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                        Row(
                          children: [
                            Expanded(child: Text(rental.listingTitle, style: FlexTextStyles.h3)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: rental.currentPaymentStatus == PaymentStatus.unpaid
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                    : const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                rental.currentPaymentStatus == PaymentStatus.unpaid ? 'Impayé' : 'Actif',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: rental.currentPaymentStatus == PaymentStatus.unpaid
                                      ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(rental.listingVille, style: TextStyle(color: FlexColors.neutral500)),
                        const SizedBox(height: 4),
                        Text('Hôte : ${rental.hoteNom}', style: TextStyle(color: FlexColors.primary500, fontWeight: FontWeight.w500, fontSize: 13)),
                        const SizedBox(height: 16),
                        _buildInfoRow('Loyer', RentalUtils.formatFCFA(rental.monthlyRent)),
                        _buildInfoRow('Caution', RentalUtils.formatFCFA(rental.caution)),
                        _buildInfoRow('Début', '${rental.startDate.day}/${rental.startDate.month}/${rental.startDate.year}'),
                        if (rental.endDate != null)
                          _buildInfoRow('Fin', '${rental.endDate!.day}/${rental.endDate!.month}/${rental.endDate!.year}'),
                        _buildInfoRow('Facturation', 'Le ${rental.billingDay} de chaque mois'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(FlexSpacing.lg),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paiements', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...rental.payments.reversed.map((p) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? FlexColors.neutral700 : FlexColors.neutral100)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          p.isSettled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 18,
                          color: p.isSettled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(RentalUtils.monthLabel(
                            int.parse(p.periodLabel.split('-')[0]),
                            int.parse(p.periodLabel.split('-')[1]),
                          ), style: const TextStyle(fontSize: 13)),
                        ),
                        Text(RentalUtils.formatFCFA(p.amount), style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
                        const SizedBox(width: 8),
                        Text(RentalUtils.paymentStatusLabel(p.status),
                          style: TextStyle(fontSize: 11, color: RentalUtils.paymentStatusColor(p.status))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label : ', style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
