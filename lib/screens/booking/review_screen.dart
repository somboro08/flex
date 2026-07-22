import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class ReviewScreen extends StatefulWidget {
  final Listing listing;
  final Booking booking;
  const ReviewScreen({super.key, required this.listing, required this.booking});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _note = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _tags = [
    'Propre', 'Confortable', 'Bien situé', 'Hôte accueillant',
    'Bon rapport qualité/prix', 'Calme', 'Sécurisé',
  ];
  final Set<String> _selectedTags = {};

  Future<void> _submit() async {
    if (_note == 0) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre avis !')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donner mon avis', style: FlexTextStyles.h3),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: FlexColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_rounded, color: FlexColors.neutral400),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.listing.titre, style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                      Text(widget.listing.ville, style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Note globale', style: FlexTextStyles.h3.copyWith(
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
            )),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _note = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < _note ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 44,
                        color: i < _note ? FlexColors.warning : FlexColors.neutral300,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_note > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  ['', 'Mauvais', 'Passable', 'Bien', 'Très bien', 'Excellent'][_note],
                  style: FlexTextStyles.label.copyWith(color: FlexColors.primary500, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Tags', style: FlexTextStyles.h3.copyWith(
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
            )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _tags.map((tag) {
                final sel = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) { _selectedTags.remove(tag); } else { _selectedTags.add(tag); }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? FlexColors.primary500.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(FlexRadius.full),
                      border: Border.all(color: sel ? FlexColors.primary500 : FlexColors.neutral300),
                    ),
                    child: Text(tag, style: FlexTextStyles.caption.copyWith(
                      color: sel ? FlexColors.primary500 : FlexColors.neutral500,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Votre commentaire', style: FlexTextStyles.h3.copyWith(
              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
            )),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Partagez votre expérience...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _note > 0 && !_isSubmitting ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Publier mon avis'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
