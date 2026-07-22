import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../utils/rental_utils.dart';

class RenewBookingScreen extends StatefulWidget {
  final MonthlyRental? rental;
  const RenewBookingScreen({super.key, this.rental});

  @override
  State<RenewBookingScreen> createState() => _RenewBookingScreenState();
}

class _RenewBookingScreenState extends State<RenewBookingScreen> {
  int _additionalMonths = 6;
  bool _agreeTerms = false;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;
    final rent = widget.rental?.monthlyRent ?? 150000;

    if (_submitted) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: const Text('Renouvellement', style: FlexTextStyles.h3), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 40, color: Color(0xFF10B981)),
                ),
                const SizedBox(height: 24),
                const Text('Bail renouvelé !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Votre demande de renouvellement a été envoyée à l\'hôte.\nVous recevrez une confirmation sous 24h.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Retour')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Renouveler le bail', style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.rental != null)
              Container(
                padding: const EdgeInsets.all(FlexSpacing.md),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
                  border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: FlexColors.primary100,
                      child: Icon(Icons.home_rounded, color: FlexColors.primary500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.rental!.listingTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(widget.rental!.listingVille, style: TextStyle(color: FlexColors.neutral500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(RentalUtils.formatFCFA(rent) + '/mois',
                          style: TextStyle(fontWeight: FontWeight.w700, color: FlexColors.primary500)),
                        Text('Fin: ${widget.rental!.effectiveEndDate.day}/${widget.rental!.effectiveEndDate.month}/${widget.rental!.effectiveEndDate.year}',
                          style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GeometricBackgroundPainter(color: const Color(0xFF10B981), opacity: 0.04),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(FlexSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prolongation', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Text('Durée supplémentaire', style: TextStyle(color: FlexColors.neutral500, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _MonthSelector(-6, '-6 mois'),
                            const SizedBox(width: 6),
                            _MonthSelector(-3, '-3 mois'),
                            const SizedBox(width: 6),
                            _MonthSelector(-1, '-1 mois'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF10B981)),
                              ),
                              child: Text('$_additionalMonths mois', style: TextStyle(fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
                            ),
                            const SizedBox(width: 6),
                            _MonthSelector(1, '+1 mois'),
                            const SizedBox(width: 6),
                            _MonthSelector(3, '+3 mois'),
                            const SizedBox(width: 6),
                            _MonthSelector(6, '+6 mois'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text('Nouvelle fin', style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                                    const SizedBox(height: 2),
                                    Text('${widget.rental?.effectiveEndDate.day ?? 1}/${widget.rental?.effectiveEndDate.month ?? 1}/${(widget.rental?.effectiveEndDate.year ?? 2026) + (_additionalMonths ~/ 12)}',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text('Coût total', style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                                    const SizedBox(height: 2),
                                    Text(RentalUtils.formatFCFA(rent * _additionalMonths),
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF10B981))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('J\'accepte les conditions de renouvellement', style: TextStyle(fontSize: 13)),
                    value: _agreeTerms,
                    onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                    activeColor: const Color(0xFF10B981),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreeTerms ? () => setState(() => _submitted = true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: FlexColors.neutral300,
                      ),
                      child: const Text('Soumettre la demande', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _MonthSelector(int delta, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() {
        _additionalMonths = (_additionalMonths + delta).clamp(1, 24);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? FlexColors.neutral600 : FlexColors.neutral200),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
