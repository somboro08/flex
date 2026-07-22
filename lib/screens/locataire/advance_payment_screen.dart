import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../utils/rental_utils.dart';

class AdvancePaymentScreen extends StatefulWidget {
  final MonthlyRental? rental;
  const AdvancePaymentScreen({super.key, this.rental});

  @override
  State<AdvancePaymentScreen> createState() => _AdvancePaymentScreenState();
}

class _AdvancePaymentScreenState extends State<AdvancePaymentScreen> {
  int _months = 1;
  String _selectedMethod = 'mtn';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;
    final rent = widget.rental?.monthlyRent ?? 150000;
    final total = rent * _months;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Paiement en avance', style: FlexTextStyles.h3),
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
                          Text('${RentalUtils.formatFCFA(widget.rental!.monthlyRent)}/mois',
                            style: TextStyle(color: FlexColors.primary500, fontWeight: FontWeight.w500)),
                        ],
                      ),
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
                      painter: GeometricBackgroundPainter(color: const Color(0xFF3B82F6), opacity: 0.04),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(FlexSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre de mois à payer', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _MonthButton('-', _months > 1, () => setState(() => _months--)),
                            Container(
                              width: 80, alignment: Alignment.center,
                              child: Text('$_months mois', style: FlexTextStyles.h2.copyWith(color: const Color(0xFF3B82F6))),
                            ),
                            _MonthButton('+', _months < 12, () => setState(() => _months++)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Moyen de paiement', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _PaymentOption('MTN Mobile Money', 'mtn', Icons.phone_android_rounded),
                  _PaymentOption('Moov Money', 'moov', Icons.phone_iphone_rounded),
                  _PaymentOption('Wave', 'wave', Icons.wifi_rounded),
                  _PaymentOption('Carte bancaire', 'card', Icons.credit_card_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(FlexSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Total à payer', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const Spacer(),
                      Text(RentalUtils.formatFCFA(total),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Soit $_months mois × ${RentalUtils.formatFCFA(rent)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showConfirmation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Effectuer le paiement', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _MonthButton(String label, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFF3B82F6) : FlexColors.neutral200,
        ),
        child: Center(child: Text(label, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: enabled ? Colors.white : FlexColors.neutral400,
        ))),
      ),
    );
  }

  Widget _PaymentOption(String label, String value, IconData icon) {
    final selected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6).withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF3B82F6) : FlexColors.neutral200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? const Color(0xFF3B82F6) : FlexColors.neutral500),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFF3B82F6), size: 18),
          ],
        ),
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmation'),
        content: Text('Voulez-vous payer ${RentalUtils.formatFCFA(widget.rental?.monthlyRent ?? (150000 * _months).toDouble())} en avance pour $_months mois ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Confirmer')),
        ],
      ),
    );
  }
}
