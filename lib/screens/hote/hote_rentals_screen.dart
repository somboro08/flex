import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../utils/rental_utils.dart';
import '../../widgets/rental_progress_widget.dart';
import 'hote_tenant_detail_screen.dart';

class HoteRentalsScreen extends StatefulWidget {
  const HoteRentalsScreen({super.key});

  @override
  State<HoteRentalsScreen> createState() => _HoteRentalsScreenState();
}

class _HoteRentalsScreenState extends State<HoteRentalsScreen> {
  String _selectedFilter = 'tous';

  final List<MonthlyRental> _sampleRentals = [
    MonthlyRental(
      id: 'r1', listingId: 'l1', listingTitle: 'Villa Ouidah', listingVille: 'Ouidah',
      listingPhoto: '', hoteId: 'h1', hoteNom: 'Moi',
      voyageurId: 'v1', voyageurNom: 'Amadou Diallo', voyageurTelephone: '+229 97 11 22 33',
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
      id: 'r2', listingId: 'l2', listingTitle: 'Studio Cotonou', listingVille: 'Cotonou',
      listingPhoto: '', hoteId: 'h1', hoteNom: 'Moi',
      voyageurId: 'v2', voyageurNom: 'Fatou Sow', voyageurTelephone: '+229 97 44 55 66',
      startDate: DateTime(2026, 3, 1), monthlyRent: 80000, billingDay: 10,
      payments: [
        RentalPayment(id: 'p8', rentalId: 'r2', periodLabel: '2026-03', amount: 80000, dueDate: DateTime(2026, 3, 10), paidAt: DateTime(2026, 3, 8), status: PaymentStatus.onTime),
        RentalPayment(id: 'p9', rentalId: 'r2', periodLabel: '2026-04', amount: 80000, dueDate: DateTime(2026, 4, 10), paidAt: DateTime(2026, 4, 7), status: PaymentStatus.onTime),
        RentalPayment(id: 'p10', rentalId: 'r2', periodLabel: '2026-05', amount: 80000, dueDate: DateTime(2026, 5, 10), paidAt: DateTime(2026, 5, 15), status: PaymentStatus.late),
        RentalPayment(id: 'p11', rentalId: 'r2', periodLabel: '2026-06', amount: 80000, dueDate: DateTime(2026, 6, 10), paidAt: DateTime(2026, 6, 9), status: PaymentStatus.onTime),
        RentalPayment(id: 'p12', rentalId: 'r2', periodLabel: '2026-07', amount: 80000, dueDate: DateTime(2026, 7, 10), status: PaymentStatus.unpaid),
      ],
      createdAt: DateTime(2026, 2, 20),
    ),
    MonthlyRental(
      id: 'r3', listingId: 'l1', listingTitle: 'Villa Ouidah', listingVille: 'Ouidah',
      listingPhoto: '', hoteId: 'h1', hoteNom: 'Moi',
      voyageurId: 'v3', voyageurNom: 'Kofi Mensah', voyageurTelephone: '+229 97 77 88 99',
      startDate: DateTime(2025, 11, 20), monthlyRent: 200000, billingDay: 5,
      payments: [
        RentalPayment(id: 'p13', rentalId: 'r3', periodLabel: '2025-11', amount: 200000, dueDate: DateTime(2025, 11, 5), paidAt: DateTime(2025, 11, 18), status: PaymentStatus.late),
        RentalPayment(id: 'p14', rentalId: 'r3', periodLabel: '2025-12', amount: 200000, dueDate: DateTime(2025, 12, 5), paidAt: DateTime(2025, 12, 3), status: PaymentStatus.onTime),
        RentalPayment(id: 'p15', rentalId: 'r3', periodLabel: '2026-01', amount: 200000, dueDate: DateTime(2026, 1, 5), paidAt: DateTime(2026, 1, 2), status: PaymentStatus.advance),
        RentalPayment(id: 'p16', rentalId: 'r3', periodLabel: '2026-02', amount: 200000, dueDate: DateTime(2026, 2, 5), paidAt: DateTime(2026, 2, 1), status: PaymentStatus.advance),
        RentalPayment(id: 'p17', rentalId: 'r3', periodLabel: '2026-03', amount: 200000, dueDate: DateTime(2026, 3, 5), paidAt: DateTime(2026, 3, 4), status: PaymentStatus.onTime),
        RentalPayment(id: 'p18', rentalId: 'r3', periodLabel: '2026-04', amount: 200000, dueDate: DateTime(2026, 4, 5), paidAt: DateTime(2026, 4, 3), status: PaymentStatus.advance),
        RentalPayment(id: 'p19', rentalId: 'r3', periodLabel: '2026-05', amount: 200000, dueDate: DateTime(2026, 5, 5), paidAt: DateTime(2026, 5, 2), status: PaymentStatus.advance),
        RentalPayment(id: 'p20', rentalId: 'r3', periodLabel: '2026-06', amount: 200000, dueDate: DateTime(2026, 6, 5), paidAt: DateTime(2026, 5, 30), status: PaymentStatus.advance),
        RentalPayment(id: 'p21', rentalId: 'r3', periodLabel: '2026-07', amount: 200000, dueDate: DateTime(2026, 7, 5), paidAt: DateTime(2026, 6, 28), status: PaymentStatus.advance),
      ],
      createdAt: DateTime(2025, 11, 15),
    ),
    MonthlyRental(
      id: 'r4', listingId: 'l3', listingTitle: 'Chambre Parakou', listingVille: 'Parakou',
      listingPhoto: '', hoteId: 'h1', hoteNom: 'Moi',
      voyageurId: 'v4', voyageurNom: 'Marie Koffi', voyageurTelephone: '+229 97 33 44 55',
      startDate: DateTime(2026, 2, 10), endDate: DateTime(2026, 8, 10), monthlyRent: 50000, billingDay: 10,
      periodStatus: RentalPeriodStatus.active,
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

  List<MonthlyRental> get _filtered {
    switch (_selectedFilter) {
      case 'probleme':
        return _sampleRentals.where((r) => r.currentPaymentStatus == PaymentStatus.late || r.currentPaymentStatus == PaymentStatus.unpaid).toList();
      case 'avance':
        return _sampleRentals.where((r) => r.currentPaymentStatus == PaymentStatus.advance).toList();
      default:
        return _sampleRentals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = RentalUtils.globalPaymentStats(_sampleRentals);
    final tenants = RentalUtils.tenantCount(_sampleRentals);
    final revenue = RentalUtils.totalMonthlyRevenue(_sampleRentals);

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Gestion locative', style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsHeader(isDark, stats, tenants, revenue),
            const SizedBox(height: 20),
            _buildFilterTabs(isDark),
            const SizedBox(height: 12),
            ..._filtered.map((r) => RentalProgressCard(
              tenantName: r.voyageurNom,
              listingTitle: '${r.listingTitle} - ${r.listingVille}',
              monthlyRent: r.monthlyRent,
              timeProgress: r.timeProgress,
              paymentProgress: r.paymentCycleProgress,
              daysUntilNextPayment: r.daysUntilNextPayment,
              lateDays: r.lateDays,
              paymentStatus: r.currentPaymentStatus,
              isActive: r.isActive,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => HoteTenantDetailScreen(rental: r),
              )),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(bool isDark, Map<String, int> stats, int tenants, double revenue) {
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
              painter: GeometricBackgroundPainter(color: FlexColors.primary500, opacity: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vue d\'ensemble', style: FlexTextStyles.h3.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatItem(icon: Icons.people_rounded, value: '$tenants', label: 'Locataires', color: FlexColors.primary500),
                    const SizedBox(width: 16),
                    _StatItem(icon: Icons.trending_up_rounded, value: RentalUtils.formatFCFA(revenue), label: 'Revenu/mois', color: const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(icon: Icons.check_circle_rounded, value: '${stats['onTime']}', label: 'À temps', color: const Color(0xFF10B981)),
                    const SizedBox(width: 16),
                    _StatItem(icon: Icons.warning_amber_rounded, value: '${stats['late']}', label: 'Retard', color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 16),
                    _StatItem(icon: Icons.trending_up_rounded, value: '${stats['advance']}', label: 'Avance', color: const Color(0xFF3B82F6)),
                    const SizedBox(width: 16),
                    _StatItem(icon: Icons.cancel_rounded, value: '${stats['unpaid']}', label: 'Impayé', color: const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final filters = ['tous', 'probleme', 'avance'];
    final labels = ['Tous les locataires', 'Problèmes', 'En avance'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _selectedFilter = filters[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _selectedFilter == filters[i]
                  ? FlexColors.primary500
                  : (isDark ? FlexColors.neutral800 : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: _selectedFilter != filters[i]
                  ? Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(labels[i], style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: _selectedFilter == filters[i] ? Colors.white : FlexColors.neutral500,
            )),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 10, color: FlexColors.neutral500)),
      ],
    );
  }
}
