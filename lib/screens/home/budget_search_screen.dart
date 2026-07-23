import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../utils/rental_utils.dart';
import '../listing/listing_detail_screen.dart';

class BudgetSearchScreen extends StatefulWidget {
  const BudgetSearchScreen({super.key});

  @override
  State<BudgetSearchScreen> createState() => _BudgetSearchScreenState();
}

class _BudgetSearchScreenState extends State<BudgetSearchScreen> {
  final _budgetController = TextEditingController();
  int? _budget;
  bool _hasSearched = false;

  final List<Listing> _sampleListings = [
    Listing(id: '1', hoteId: 'h1', titre: 'Chambre calme Madame Akobi', description: 'Chambre propre avec ventilateur', ville: 'Parakou', quartier: 'Zongo', adresse: 'Rue des Artisans', latitude: 9.337, longitude: 2.628, prixParNuit: 5000, photos: [], equipements: ['WiFi', 'Ventilateur'], certification: CertificationStatus.certified, note: 4.8, nombreAvis: 23, createdAt: DateTime.now()),
    Listing(id: '6', hoteId: 'h6', titre: 'Chambre économique', description: 'Chambre simple et propre', ville: 'Parakou', quartier: 'Ganou', adresse: 'Route de Malanville', latitude: 9.340, longitude: 2.630, prixParNuit: 3000, photos: [], equipements: ['Ventilateur'], certification: CertificationStatus.certified, note: 4.2, nombreAvis: 45, createdAt: DateTime.now()),
    Listing(id: '8', hoteId: 'h8', titre: 'Studio Akpakpa', description: 'Petit studio meublé', ville: 'Cotonou', quartier: 'Akpakpa', adresse: 'Rue des Pêcheurs', latitude: 6.370, longitude: 2.440, prixParNuit: 7000, photos: [], equipements: ['WiFi', 'Eau chaude'], certification: CertificationStatus.certified, note: 4.3, nombreAvis: 15, createdAt: DateTime.now()),
    Listing(id: '9', hoteId: 'h9', titre: 'Chambre chez l\'habitant', description: 'Chambre chez famille accueillante', ville: 'Abomey', quartier: 'Gbègo', adresse: 'Quartier Gbègo', latitude: 7.180, longitude: 1.988, prixParNuit: 4000, photos: [], equipements: ['Ventilateur', 'Petit-déjeuner'], certification: CertificationStatus.certified, note: 4.6, nombreAvis: 31, createdAt: DateTime.now()),
    Listing(id: '10', hoteId: 'h10', titre: 'Nuitée pas chère', description: 'Chambre d\'hôte économique', ville: 'Natitingou', quartier: 'Perma', adresse: 'Route nationale', latitude: 10.304, longitude: 1.376, prixParNuit: 2500, photos: [], equipements: ['Ventilateur'], certification: CertificationStatus.certified, note: 4.1, nombreAvis: 52, createdAt: DateTime.now()),
  ];

  List<Listing> get _results {
    if (_budget == null) return [];
    return _sampleListings.where((l) => l.prixParNuit <= _budget!).toList()
      ..sort((a, b) => a.prixParNuit.compareTo(b.prixParNuit));
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;
    final results = _results;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Mon budget', style: FlexTextStyles.h3),
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
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                gradient: const LinearGradient(colors: [FlexColors.primary500, FlexColors.primary600]),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GeometricBackgroundPainter(color: Colors.white, opacity: 0.06),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(FlexSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quel est votre budget ?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Trouvez les logements adaptés à votre budget', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text('FCFA', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _budgetController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                        decoration: InputDecoration(
                                          hintText: 'ex: 15000',
                                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 16),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        onSubmitted: (_) => _search(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _search,
                              child: Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.search_rounded, color: FlexColors.primary500, size: 22),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _BudgetChip('5000', () => _setBudget(5000)),
                            const SizedBox(width: 6),
                            _BudgetChip('10 000', () => _setBudget(10000)),
                            const SizedBox(width: 6),
                            _BudgetChip('15 000', () => _setBudget(15000)),
                            const SizedBox(width: 6),
                            _BudgetChip('25 000', () => _setBudget(25000)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_hasSearched) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('${results.length} résultat(s)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
                  const Spacer(),
                  Text('Budget max: ${RentalUtils.formatFCFA(_budget!.toDouble())}', style: TextStyle(fontSize: 12, color: FlexColors.primary500, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: FlexColors.neutral300),
                      const SizedBox(height: 12),
                      Text('Aucun logement trouvé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FlexColors.neutral400)),
                      Text('Essayez d\'augmenter votre budget', style: TextStyle(color: FlexColors.neutral400)),
                    ],
                  ),
                )
              else
                ...results.map((l) => _buildResultCard(l, isDark, cardColor)),
            ],
          ],
        ),
      ),
    );
  }

  void _search() {
    final v = int.tryParse(_budgetController.text);
    if (v == null || v <= 0) return;
    setState(() { _budget = v; _hasSearched = true; });
  }

  void _setBudget(int amount) {
    _budgetController.text = amount.toString();
    _search();
  }

  Widget _BudgetChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('$label FCFA', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildResultCard(Listing listing, bool isDark, Color cardColor) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: FlexColors.primary100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(Icons.image_rounded, color: FlexColors.primary300, size: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.titre, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${listing.ville} · ${listing.quartier}', style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${listing.prixParNuit.toInt()} FCFA', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: FlexColors.primary500)),
                      const Text('/nuit', style: TextStyle(fontSize: 10, color: FlexColors.neutral400)),
                      const SizedBox(width: 8),
                      if (listing.isCertified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: FlexColors.certified.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('Certifié', style: TextStyle(fontSize: 9, color: FlexColors.certified, fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: FlexColors.neutral400, size: 20),
          ],
        ),
      ),
    );
  }
}
