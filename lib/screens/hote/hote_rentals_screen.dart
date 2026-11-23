import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../repositories/rental_repository.dart';
import '../../utils/rental_utils.dart';
import '../../widgets/rental_progress_widget.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import 'hote_tenant_detail_screen.dart';

class HoteRentalsScreen extends StatefulWidget {
  const HoteRentalsScreen({super.key});

  @override
  State<HoteRentalsScreen> createState() => _HoteRentalsScreenState();
}

class _HoteRentalsScreenState extends State<HoteRentalsScreen> {
  String _selectedFilter = 'tous';
  bool _isLoading = true;
  final _rentalRepo = RentalRepository();
  List<MonthlyRental> _rentals = [];

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
        _rentals = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading rentals: $e');
      if (!mounted) return;
      setState(() {
        _rentals = [];
        _isLoading = false;
      });
    }
  }

  List<MonthlyRental> get _filtered {
    switch (_selectedFilter) {
      case 'probleme':
        return _rentals.where((r) => r.currentPaymentStatus == PaymentStatus.late || r.currentPaymentStatus == PaymentStatus.unpaid).toList();
      case 'avance':
        return _rentals.where((r) => r.currentPaymentStatus == PaymentStatus.advance).toList();
      default:
        return _rentals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = RentalUtils.globalPaymentStats(_rentals);
    final tenants = RentalUtils.tenantCount(_rentals);
    final revenue = RentalUtils.totalMonthlyRevenue(_rentals);

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Gestion locative', style: FlexTextStyles.h3),
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
                      _buildStatsHeader(isDark, stats, tenants, revenue),
                      const SizedBox(height: 20),
                      _buildFilterTabs(isDark),
                      const SizedBox(height: 12),
                      if (_filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.house_siding_rounded, size: 56, color: FlexColors.neutral300),
                                const SizedBox(height: 12),
                                const Text('Aucune location active',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FlexColors.neutral500)),
                              ],
                            ),
                          ),
                        )
                      else
                        Builder(builder: (ctx) {
                          final cols = ctx.isDesktop ? 2 : 1;
                          if (cols == 1) {
                            return Column(
                              children: _filtered.map((r) => _buildRentalCard(r)).toList(),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _buildRentalCard(_filtered[i]),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRentalCard(MonthlyRental r) {
    return RentalProgressCard(
      tenantName: r.voyageurNom,
      listingTitle: '${r.listingTitle} - ${r.listingVille}',
      monthlyRent: r.monthlyRent,
      timeProgress: r.timeProgress,
      paymentProgress: r.paymentCycleProgress,
      daysUntilNextPayment: r.daysUntilNextPayment,
      lateDays: r.lateDays,
      paymentStatus: r.currentPaymentStatus,
      isActive: r.isActive,
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => HoteTenantDetailScreen(rental: r),
        ));
        _load();
      },
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
