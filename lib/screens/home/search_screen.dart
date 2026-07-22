import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../widgets/listing_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tout';
  
  final List<String> _categories = [
    'Tout', 'Studio', 'Appartement', 'Chambre', 'Villa'
  ];

  // Mock results
  final List<Listing> _allResults = [
    Listing(
      id: 's1',
      hoteId: 'h1',
      titre: 'Appartement moderne Cotonou',
      description: 'Bel appartement spacieux en plein cœur de Fidjrossé.',
      ville: 'Cotonou',
      quartier: 'Fidjrossé',
      adresse: 'Route des Pêches',
      latitude: 6.35,
      longitude: 2.38,
      prixParNuit: 15000,
      photos: [],
      equipements: ['WiFi', 'Climatisation', 'Cuisine'],
      certification: CertificationStatus.certified,
      note: 4.9,
      nombreAvis: 15,
      createdAt: DateTime.now(),
    ),
    Listing(
      id: 's2',
      hoteId: 'h2',
      titre: 'Villa de vacances Ouidah',
      description: 'Villa avec piscine et vue sur mer pour vos vacances.',
      ville: 'Ouidah',
      quartier: 'Kpasse',
      adresse: 'Route de la Plage',
      latitude: 6.36,
      longitude: 2.08,
      prixParNuit: 35000,
      photos: [],
      equipements: ['Piscine', 'WiFi', 'Jardin'],
      certification: CertificationStatus.certified,
      note: 4.7,
      nombreAvis: 8,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Recherche', style: FlexTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.md),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(
                  color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Où voulez-vous aller ?',
                  icon: Icon(Icons.search_rounded, color: FlexColors.primary500),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isSelected = _categories[i] == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? FlexColors.primary500 : Colors.transparent,
                      borderRadius: BorderRadius.circular(FlexRadius.full),
                      border: Border.all(
                        color: isSelected ? FlexColors.primary500 : (isDark ? FlexColors.neutral700 : FlexColors.neutral200),
                      ),
                    ),
                    child: Text(
                      _categories[i],
                      style: FlexTextStyles.label.copyWith(
                        color: isSelected ? Colors.white : (isDark ? FlexColors.neutral400 : FlexColors.neutral600),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: FlexSpacing.md),

          // Results
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(FlexSpacing.md),
              itemCount: _allResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: FlexSpacing.md),
              itemBuilder: (context, i) => ListingCard(listing: _allResults[i]),
            ),
          ),
        ],
      ),
    );
  }
}
