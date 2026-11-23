import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/listing_repository.dart';
import '../../widgets/listing_card.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import '../../shared/widgets/adaptive_grid.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _searchController = TextEditingController(text: widget.initialQuery);
  String _selectedCategory = 'Tout';
  RangeValues _prixRange = const RangeValues(3000, 50000);
  String _selectedVille = 'Toutes';
  Set<String> _selectedEquipements = {};
  bool _showFilters = false;
  bool _certifieOnly = false;

  final _categories = ['Tout', 'Studio', 'Appartement', 'Chambre', 'Villa'];
  final _villes = ['Toutes', 'Parakou', 'Cotonou', 'Abomey', 'Natitingou', 'Porto-Novo'];
  final _equipements = ['WiFi', 'Climatisation', 'Ventilateur', 'Eau chaude', 'Cuisine', 'Parking', 'Jardin'];

  final _listingRepo = ListingRepository();
  List<Listing> _allResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final listings = await _listingRepo.getListings();
      if (!mounted) return;
      setState(() {
        _allResults = listings;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading search listings: $e');
      if (!mounted) return;
      setState(() {
        _allResults = [];
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filteredResults {
    return _allResults.where((l) {
      if (_selectedCategory != 'Tout' && !l.titre.toLowerCase().contains(_selectedCategory.toLowerCase())) return false;
      if (_selectedVille != 'Toutes' && l.ville != _selectedVille) return false;
      if (l.prixParNuit < _prixRange.start || l.prixParNuit > _prixRange.end) return false;
      if (_certifieOnly && l.certification != CertificationStatus.certified) return false;
      if (_selectedEquipements.isNotEmpty) {
        if (!_selectedEquipements.every((e) => l.equipements.contains(e))) return false;
      }
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        if (!l.titre.toLowerCase().contains(q) &&
            !l.ville.toLowerCase().contains(q) &&
            !l.quartier.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Recherche', style: FlexTextStyles.h3),
        centerTitle: !isDesktop,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Tooltip(
            message: _showFilters ? 'Masquer les filtres' : 'Afficher les filtres',
            child: IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list_rounded,
                color: _showFilters ? FlexColors.primary500 : FlexColors.neutral400,
              ),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
        ],
      ),
      body: AdaptiveContentContainer(
        child: isDesktop && _showFilters
            // Desktop: side-by-side filters + results
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 280,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark),
                          const SizedBox(height: 8),
                          _buildFilters(isDark),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  const SizedBox(width: 16),
                  Expanded(child: _buildResultsColumn(isDark)),
                ],
              )
            // Mobile / Tablet: stacked layout
            : Column(
                children: [
                  _buildSearchBar(isDark),
                  if (_showFilters) _buildFilters(isDark),
                  _buildCategories(isDark),
                  Expanded(child: _buildResultsColumn(isDark)),
                ],
              ),
      ),
    );
  }

  Widget _buildResultsColumn(bool isDark) {
    if (!context.isDesktop) {
      return Column(
        children: [
          _buildCategories(isDark),
          Expanded(child: _buildResults(isDark)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategories(isDark),
        const SizedBox(height: 8),
        Expanded(child: _buildResults(isDark)),
      ],
    );
  }

  Widget _buildResults(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: FlexColors.primary500));
    }
    if (_filteredResults.isEmpty) return _buildEmptyState();

    return AdaptiveGrid<Listing>(
      items: _filteredResults,
      mobileCrossAxisCount: 1,
      tabletCrossAxisCount: 2,
      desktopCrossAxisCount: 3,
      largeDesktopCrossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: context.isMobile ? 0.92 : 0.8,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, listing, i) => ListingCard(listing: listing),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FlexSpacing.sm, horizontal: 0),
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
            filled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _villes.map((v) => _FilterChip(
              label: v, selected: _selectedVille == v,
              onTap: () => setState(() => _selectedVille = v),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Text('Prix par nuit', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
          RangeSlider(
            values: _prixRange,
            min: 2000, max: 100000, divisions: 20,
            labels: RangeLabels('${_prixRange.start.toInt()} FCFA', '${_prixRange.end.toInt()} FCFA'),
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
        padding: EdgeInsets.symmetric(
          horizontal: context.isDesktop ? 0 : FlexSpacing.md,
          vertical: 4,
        ),
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
                border: Border.all(
                  color: isSelected ? FlexColors.primary500 : (isDark ? FlexColors.neutral700 : FlexColors.neutral200),
                ),
              ),
              child: Text(
                _categories[i],
                style: FlexTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : (isDark ? FlexColors.neutral400 : FlexColors.neutral600),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
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
          const Icon(Icons.search_off_rounded, size: 64, color: FlexColors.neutral300),
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
  final String label;
  final bool selected;
  final VoidCallback onTap;
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
        child: Text(
          label,
          style: FlexTextStyles.caption.copyWith(
            color: selected ? FlexColors.primary500 : FlexColors.neutral500,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
