import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../utils/rental_utils.dart';
import '../../widgets/listing_card.dart';
import '../listing/listing_detail_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _selectedVille = 'Toutes';
  String _selectedQuartier = 'Tous';
  bool _showMap = false;

  final _villes = ['Toutes', 'Parakou', 'Cotonou', 'Abomey', 'Natitingou', 'Porto-Novo'];
  final _quartiers = {
    'Toutes': ['Tous'],
    'Parakou': ['Tous', 'Zongo', 'Kpébié', 'Alaga', 'Ganou', 'Baka'],
    'Cotonou': ['Tous', 'Akpakpa', 'Cadjehoun', 'Haie Vive', 'Fidjrossè', 'Sainte Rita'],
    'Abomey': ['Tous', 'Centre', 'Gbègo', 'Zobé'],
    'Natitingou': ['Tous', 'Kouffou', 'Perma', 'Tantéga'],
    'Porto-Novo': ['Tous', 'Akouédo', 'Djègan', 'Louho'],
  };

  final _promos = [
    _PromoData('Louez cette villa et obtenez 15% de réduction', 'Villa haut standing à partir de 150 000 FCFA/mois', FlexColors.primary500),
    _PromoData('Réservation express - Économisez 20%', 'Court séjour à prix réduit dans nos chambres certifiées', const Color(0xFF8B5CF6)),
    _PromoData('Cohabitation ? Payez moins cher', 'Partagez un logement et divisez le loyer par 2', const Color(0xFF10B981)),
    _PromoData('Offre spéciale étudiant', '-25% sur votre première location avec Flex', const Color(0xFFF59E0B)),
  ];

  List<Listing> _getFilteredListings() {
    return _sampleListings.where((l) {
      if (_selectedVille != 'Toutes' && l.ville != _selectedVille) return false;
      if (_selectedQuartier != 'Tous' && l.quartier != _selectedQuartier) return false;
      return true;
    }).toList();
  }

  final List<Listing> _sampleListings = [
    Listing(id: '1', hoteId: 'h1', titre: 'Chambre calme Madame Akobi', description: 'Chambre propre', ville: 'Parakou', quartier: 'Zongo', adresse: 'Rue des Artisans', latitude: 9.337, longitude: 2.628, prixParNuit: 5000, photos: [], equipements: ['WiFi', 'Ventilateur'], certification: CertificationStatus.certified, note: 4.8, nombreAvis: 23, createdAt: DateTime.now()),
    Listing(id: '2', hoteId: 'h2', titre: 'Studio meublé Centre-ville', description: 'Studio indépendant', ville: 'Parakou', quartier: 'Kpébié', adresse: 'Avenue Liberté', latitude: 9.341, longitude: 2.624, prixParNuit: 8500, photos: [], equipements: ['Climatisation', 'Cuisine'], certification: CertificationStatus.certified, note: 4.6, nombreAvis: 11, createdAt: DateTime.now()),
    Listing(id: '3', hoteId: 'h3', titre: 'Chambre familiale jardin', description: 'Grande chambre', ville: 'Parakou', quartier: 'Alaga', adresse: 'Quartier Alaga', latitude: 9.330, longitude: 2.631, prixParNuit: 6500, photos: [], equipements: ['Ventilateur', 'Jardin'], certification: CertificationStatus.pending, note: 4.4, nombreAvis: 7, createdAt: DateTime.now()),
    Listing(id: '4', hoteId: 'h4', titre: 'Villa Ouidah plage', description: 'Villa avec piscine', ville: 'Cotonou', quartier: 'Fidjrossè', adresse: 'Bord de mer', latitude: 6.360, longitude: 2.086, prixParNuit: 35000, photos: [], equipements: ['Piscine', 'Climatisation', 'WiFi'], certification: CertificationStatus.certified, note: 4.9, nombreAvis: 34, createdAt: DateTime.now()),
    Listing(id: '5', hoteId: 'h5', titre: 'Appartement moderne', description: 'Appartement tout équipé', ville: 'Cotonou', quartier: 'Cadjehoun', adresse: 'Boulevard de France', latitude: 6.357, longitude: 2.400, prixParNuit: 12000, photos: [], equipements: ['Climatisation', 'WiFi', 'Parking'], certification: CertificationStatus.certified, note: 4.5, nombreAvis: 18, createdAt: DateTime.now()),
    Listing(id: '6', hoteId: 'h6', titre: 'Chambre économique', description: 'Chambre simple', ville: 'Parakou', quartier: 'Ganou', adresse: 'Route de Malanville', latitude: 9.340, longitude: 2.630, prixParNuit: 3000, photos: [], equipements: ['Ventilateur'], certification: CertificationStatus.certified, note: 4.2, nombreAvis: 45, createdAt: DateTime.now()),
    Listing(id: '7', hoteId: 'h7', titre: 'Villa haut standing', description: 'Villa luxueuse', ville: 'Abomey', quartier: 'Centre', adresse: 'Place de la Nation', latitude: 7.183, longitude: 1.991, prixParNuit: 45000, photos: [], equipements: ['Piscine', 'Climatisation', 'Jardin', 'Parking'], certification: CertificationStatus.certified, note: 4.7, nombreAvis: 9, createdAt: DateTime.now()),
    Listing(id: '8', hoteId: 'h8', titre: 'Studio Akpakpa', description: 'Petit studio meublé', ville: 'Cotonou', quartier: 'Akpakpa', adresse: 'Rue des Pêcheurs', latitude: 6.370, longitude: 2.440, prixParNuit: 7000, photos: [], equipements: ['WiFi', 'Eau chaude'], certification: CertificationStatus.certified, note: 4.3, nombreAvis: 15, createdAt: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;
    final filtered = _getFilteredListings();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.category, style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildCarousel(isDark)),
          SliverToBoxAdapter(child: _buildFilterBar(isDark, cardColor)),
          if (_showMap)
            SliverToBoxAdapter(child: _buildMap(isDark))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final listing = filtered[i];
                    final offset = i.isEven ? 0.0 : 20.0;
                    return Padding(
                      padding: EdgeInsets.only(top: i > 0 ? (i.isEven ? 0 : 20) : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: i.isEven
                                ? _buildListingCard(listing, isDark)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: i.isEven
                                ? const SizedBox.shrink()
                                : _buildListingCard(listing, isDark),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildCarousel(bool isDark) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: _promos.length,
        itemBuilder: (_, i) {
          final p = _promos[i];
          return Container(
            margin: const EdgeInsets.fromLTRB(FlexSpacing.md, 4, FlexSpacing.md, FlexSpacing.md),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(FlexRadius.lg)),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [p.color, p.color.withValues(alpha: 0.7)]),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: GeometricBackgroundPainter(color: Colors.white, opacity: 0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(p.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Voir l\'offre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(bool isDark, Color cardColor) {
    final quartiers = _quartiers[_selectedVille] ?? ['Tous'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVille,
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded, size: 18, color: FlexColors.neutral500),
                      style: TextStyle(fontSize: 13, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800),
                      items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() { _selectedVille = v!; _selectedQuartier = 'Tous'; }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _showMap = !_showMap),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _showMap ? FlexColors.primary500 : cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _showMap ? FlexColors.primary500 : (isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
                  ),
                  child: Icon(
                    _showMap ? Icons.format_list_bulleted_rounded : Icons.map_rounded,
                    size: 18, color: _showMap ? Colors.white : FlexColors.neutral500,
                  ),
                ),
              ),
            ],
          ),
          if (!_showMap) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quartiers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final selected = quartiers[i] == _selectedQuartier;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedQuartier = quartiers[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? FlexColors.primary500 : (isDark ? FlexColors.neutral800 : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: !selected ? Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200) : null,
                      ),
                      child: Text(quartiers[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : FlexColors.neutral500)),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          child: FlutterMap(
            options: const MapOptions(initialCenter: LatLng(9.34, 2.63), initialZoom: 7.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.flex.app'),
              MarkerLayer(markers: _getFilteredListings().map((l) => Marker(
                point: LatLng(l.latitude, l.longitude),
                width: 40, height: 40,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l))),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: FlexColors.primary500, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
                    child: Icon(Icons.home_rounded, size: 14, color: Colors.white),
                  ),
                ),
              )).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(Listing listing, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(FlexRadius.md),
          border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: FlexColors.primary100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(Icons.image_rounded, color: FlexColors.primary300, size: 28)),
            ),
            const SizedBox(height: 8),
            Text(listing.titre, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 10, color: FlexColors.neutral400),
                const SizedBox(width: 2),
                Text(listing.quartier, style: TextStyle(fontSize: 10, color: FlexColors.neutral500)),
                const Spacer(),
                if (listing.isCertified)
                  Icon(Icons.verified_rounded, size: 12, color: FlexColors.certified),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${listing.prixParNuit.toInt()} FCFA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: FlexColors.primary500)),
                const Text('/nuit', style: TextStyle(fontSize: 9, color: FlexColors.neutral400)),
                const Spacer(),
                Row(children: [
                  Icon(Icons.star_rounded, size: 10, color: FlexColors.warning),
                  Text(listing.note.toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoData {
  final String title; final String subtitle; final Color color;
  const _PromoData(this.title, this.subtitle, this.color);
}
