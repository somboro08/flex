import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class VisitRequestScreen extends StatefulWidget {
  final Listing listing;
  const VisitRequestScreen({super.key, required this.listing});

  @override
  State<VisitRequestScreen> createState() => _VisitRequestScreenState();
}

class _VisitRequestScreenState extends State<VisitRequestScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = 'Matin (9h-12h)';
  final _messageController = TextEditingController();
  bool _submitted = false;

  final _slots = ['Matin (9h-12h)', 'Après-midi (14h-17h)', 'Soirée (17h-19h)'];

  @override
  void dispose() {
    _messageController.dispose();
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
        appBar: AppBar(title: const Text('Visite programmée', style: FlexTextStyles.h3), leading: const BackButton(), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 40, color: Color(0xFF10B981)),
                ),
                const SizedBox(height: 24),
                const Text('Visite programmée !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Votre visite chez ${widget.listing.titre} a été demandée.\nL\'hôte vous confirmera le créneau sous 24h.',
                  textAlign: TextAlign.center, style: TextStyle(color: FlexColors.neutral500)),
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
        title: const Text('Réserver une visite', style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: FlexColors.primary100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.home_rounded, color: FlexColors.primary500)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.listing.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${widget.listing.ville} · ${widget.listing.quartier}', style: TextStyle(color: FlexColors.neutral500, fontSize: 13)),
                    ],
                  )),
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
                  const Text('Date de visite', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateOption(DateTime.now().add(const Duration(days: 1)), _selectedDate, () => setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1)))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateOption(DateTime.now().add(const Duration(days: 2)), _selectedDate, () => setState(() => _selectedDate = DateTime.now().add(const Duration(days: 2)))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateOption(DateTime.now().add(const Duration(days: 3)), _selectedDate, () => setState(() => _selectedDate = DateTime.now().add(const Duration(days: 3)))),
                      ),
                    ],
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
                  const Text('Créneau horaire', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  ..._slots.map((s) => _SlotOption(s, _selectedSlot, () => setState(() => _selectedSlot = s))),
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
                  const Text('Message (optionnel)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Dites quelque chose à l\'hôte...',
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
                  backgroundColor: FlexColors.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Programmer la visite', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateOption extends StatelessWidget {
  final DateTime date; final DateTime selected; final VoidCallback onTap;
  const _DateOption(this.date, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) {
    final isSel = date.day == selected.day && date.month == selected.month;
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? FlexColors.primary500 : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? FlexColors.primary500 : FlexColors.neutral200),
        ),
        child: Column(
          children: [
            Text(days[date.weekday - 1], style: TextStyle(color: isSel ? Colors.white : FlexColors.neutral500, fontSize: 11)),
            Text('${date.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSel ? Colors.white : null)),
            Text('${date.month}/${date.year}', style: TextStyle(color: isSel ? Colors.white70 : FlexColors.neutral400, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SlotOption extends StatelessWidget {
  final String label; final String selected; final VoidCallback onTap;
  const _SlotOption(this.label, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) {
    final isSel = label == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSel ? FlexColors.primary500.withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? FlexColors.primary500 : FlexColors.neutral200),
        ),
        child: Row(
          children: [
            Icon(isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, size: 18, color: isSel ? FlexColors.primary500 : FlexColors.neutral400),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: isSel ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
