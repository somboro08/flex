import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../repositories/rental_repository.dart';
import '../../utils/rental_utils.dart';
import '../../widgets/rental_progress_widget.dart';
import '../../core/responsive/content_container.dart';
import '../../shared/widgets/adaptive_overlay.dart';
import '../../shared/widgets/adaptive_dialog_content.dart';

class LocataireRentalsScreen extends StatefulWidget {
  const LocataireRentalsScreen({super.key});

  @override
  State<LocataireRentalsScreen> createState() => _LocataireRentalsScreenState();
}

class _LocataireRentalsScreenState extends State<LocataireRentalsScreen> {
  final _rentalRepo = RentalRepository();
  List<MonthlyRental> _myRentals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _rentalRepo.getRentals();
      if (!mounted) return;
      setState(() {
        _myRentals = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading rentals: $e');
      if (!mounted) return;
      setState(() {
        _myRentals = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalMonthly = _myRentals.where((r) => r.isActive).fold(0.0, (s, r) => s + r.monthlyRent);

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Mes locations', style: FlexTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FlexColors.primary500))
          : RefreshIndicator(
              onRefresh: _load,
              color: FlexColors.primary500,
              child: AdaptiveContentContainer(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: FlexSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    _buildHeaderSummary(isDark, totalMonthly),
                    const SizedBox(height: 20),
                    if (_myRentals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.house_siding_rounded, size: 56, color: FlexColors.neutral300),
                              const SizedBox(height: 12),
                              Text('Aucune location en cours', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FlexColors.neutral500)),
                            ],
                          ),
                        ),
                      )
                    else
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
              onTap: () => context.push('/advance-payment'),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.replay_rounded, label: 'Renouveler',
              color: const Color(0xFF10B981),
              onTap: () => context.push('/renew-booking'),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.receipt_long_rounded, label: 'Remboursement',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push('/refund-request'),
            )),
          ],
        ),
      ],
    );
  }

  void _showRentalActions(BuildContext context, MonthlyRental rental) {
    AdaptiveOverlay.show(
      context: context,
      child: AdaptiveDialogContent(
        title: 'Gérer ma location',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.payments_rounded, color: Color(0xFF3B82F6)),
              title: const Text('Payer en avance'),
              subtitle: const Text('Effectuer un paiement anticipé'),
              onTap: () { Navigator.pop(context); context.push('/advance-payment', extra: rental); },
            ),
            ListTile(
              leading: const Icon(Icons.replay_rounded, color: Color(0xFF10B981)),
              title: const Text('Renouveler le bail'),
              subtitle: const Text('Prolonger votre période de location'),
              onTap: () { Navigator.pop(context); context.push('/renew-booking', extra: rental); },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF8B5CF6)),
              title: const Text('Demander un remboursement'),
              subtitle: const Text('Soumettre une demande de remboursement'),
              onTap: () { Navigator.pop(context); context.push('/refund-request', extra: rental); },
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
