import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/rental_models.dart';
import '../../utils/rental_utils.dart';

class RefundRequestScreen extends StatefulWidget {
  final MonthlyRental? rental;
  const RefundRequestScreen({super.key, this.rental});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  String _reason = 'autre';
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;

    if (_submitted) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: const Text('Remboursement', style: FlexTextStyles.h3), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 40, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(height: 24),
                const Text('Demande soumise !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Votre demande de remboursement a été envoyée.\nL\'hôte vous répondra sous 48h.',
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
        title: const Text('Demande de remboursement', style: FlexTextStyles.h3),
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
                          Text(RentalUtils.formatFCFA(widget.rental!.monthlyRent) + '/mois',
                            style: TextStyle(color: FlexColors.primary500, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(FlexSpacing.lg),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Motif du remboursement', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...['caution', 'sursis', 'annulation', 'autre'].map((r) => _ReasonRadio(
                    label: r == 'caution' ? 'Caution' : r == 'sursis' ? 'Sursis de paiement' : r == 'annulation' ? 'Annulation' : 'Autre',
                    value: r,
                  )),
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
                  Text('Commentaires (optionnel)', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Expliquez votre demande...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _submitted = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Soumettre la demande', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ReasonRadio({required String label, required String value}) {
    final selected = _reason == value;
    return GestureDetector(
      onTap: () => setState(() => _reason = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8B5CF6).withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF8B5CF6) : FlexColors.neutral200),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18, color: selected ? const Color(0xFF8B5CF6) : FlexColors.neutral400),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
