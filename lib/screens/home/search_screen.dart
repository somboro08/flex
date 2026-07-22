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
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tout';
  RangeValues _prixRange = const RangeValues(3000, 50000);
  String _selectedVille = 'Toutes';
  Set<String> _selectedEquipements = {};
  bool _showFilters = false;
  bool _certifieOnly = false;

  final _categories = ['Tout', 'Studio', 'Appartement', 'Chambre', 'Villa'];
  final _villes = ['Toutes', 'Parakou', 'Cotonou', 'Abomey', 'Natitingou', 'Porto-Novo'];
  final _equipements = ['WiFi', 'Climatisation', 'Ventilateur', 'Eau chaude', 'Cuisine', 'Parking', 'Jardin'];

  final List<Listing> _allResults = [
    Listing(id: 's1', hoteId: 'h1', titre: 'Appartement moderne Cotonou',
      description: 'Bel appartement spacieux.', ville: 'Cotonou',
      quartier: 'Fidjrossé', adresse: 'Route des Pêches', latitude: 6.35,
      longitude: 2.38, prixParNuit: 15000, photos: [],
      equipements: ['WiFi', 'Climatisation', 'Cuisine'],
      certification: CertificationStatus.certified, note: 4.9, nombreAvis: 15, createdAt: DateTime.now()),
    Listing(id: 's2', hoteId: 'h2', titre: 'Villa de vacances Ouidah',
      description: 'Villa avec piscine.', ville: 'Ouidah',
      quartier: 'Kpasse', adresse: 'Route de la Plage', latitude: 6.36,
      longitude: 2.08, prixParNuit: 35000, photos: [],
      equipements: ['Piscine', 'WiFi', 'Jardin'],
      certification: CertificationStatus.certified, note: 4.7, nombreAvis: 8, createdAt: DateTime.now()),
    Listing(id: 's3', hoteId: 'h3', titre: 'Chambre économique Parakou',
      description: 'Chambre simple et propre.', ville: 'Parakou',
      quartier: 'Zongo', adresse: 'Rue Principale', latitude: 9.34,
      longitude: 2.63, prixParNuit: 5000, photos: [],
      equipements: ['Ventilateur', 'WiFi'],
      certification: CertificationStatus.pending, note: 4.2, nombreAvis: 5, createdAt: DateTime.now()),
  ];

  List<Listing> get _filteredResults {
    return _allResults.where((l) {
      if (_selectedCategory != 'Tout' && !l.titre.toLowerCase().contains(_selectedCategory.toLowerCase())) {
        return false;
      }
      if (_selectedVille != 'Toutes' && l.ville != _selectedVille) return false;
      if (l.prixParNuit < _prixRange.start || l.prixParNuit > _prixRange.end) return false;
      if (_certifieOnly && l.certification != CertificationStatus.certified) return false;
      if (_selectedEquipements.isNotEmpty) {
        if (!_selectedEquipements.every((e) => l.equipements.contains(e))) return false;
      }
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        if (!l.titre.toLowerCase().contains(q) && !l.ville.toLowerCase().contains(q) && !l.quartier.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

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
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list_rounded,
                color: _showFilters ? FlexColors.primary500 : FlexColors.neutral400),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          if (_showFilters) _buildFilters(isDark),
          _buildCategories(isDark),
          Expanded(
            child: _filteredResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(FlexSpacing.md),
                    itemCount: _filteredResults.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListingCard(listing: _filteredResults[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(FlexSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Ville, quartier, logement...',
            icon: Icon(Icons.search_rounded, color: FlexColors.primary500),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filtres', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _prixRange = const RangeValues(3000, 50000);
                  _selectedVille = 'Toutes';
                  _selectedEquipements.clear();
                  _certifieOnly = false;
                }),
                child: Text('Réinitialiser', style: FlexTextStyles.caption.copyWith(color: FlexColors.primary500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Ville', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _villes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => _FilterChip(
                label: _villes[i], selected: _selectedVille == _villes[i],
                onTap: () => setState(() => _selectedVille = _villes[i]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Prix par nuit', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
          RangeSlider(
            values: _prixRange,
            min: 2000, max: 100000,
            divisions: 20,
            labels: RangeLabels(
              '${_prixRange.start.toInt()} FCFA',
              '${_prixRange.end.toInt()} FCFA',
            ),
            activeColor: FlexColors.primary500,
            onChanged: (v) => setState(() => _prixRange = v),
          ),
          Row(
            children: [
              Checkbox(
                value: _certifieOnly,
                onChanged: (v) => setState(() => _certifieOnly = v ?? false),
                activeColor: FlexColors.primary500,
              ),
              Text('Logements certifiés uniquement', style: FlexTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text('Équipements', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _equipements.map((e) => _FilterChip(
              label: e, selected: _selectedEquipements.contains(e),
              onTap: () => setState(() {
                if (_selectedEquipements.contains(e)) {
                  _selectedEquipements.remove(e);
                } else {
                  _selectedEquipements.add(e);
                }
              }),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = _categories[i] == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? FlexColors.primary500 : Colors.transparent,
                borderRadius: BorderRadius.circular(FlexRadius.full),
                border: Border.all(color: isSelected ? FlexColors.primary500 : (isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
              ),
              child: Text(_categories[i], style: FlexTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : (isDark ? FlexColors.neutral400 : FlexColors.neutral600),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: FlexColors.neutral300),
          const SizedBox(height: 16),
          Text('Aucun résultat', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
          const SizedBox(height: 8),
          Text('Essayez de modifier vos filtres', style: FlexTextStyles.body.copyWith(color: FlexColors.neutral400)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? FlexColors.primary500.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(FlexRadius.full),
          border: Border.all(color: selected ? FlexColors.primary500 : FlexColors.neutral300),
        ),
        child: Text(label, style: FlexTextStyles.caption.copyWith(
          color: selected ? FlexColors.primary500 : FlexColors.neutral500,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }
}
