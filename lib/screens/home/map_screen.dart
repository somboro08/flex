import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/listing_repository.dart';
import '../../shared/widgets/adaptive_overlay.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _listingRepo = ListingRepository();
  List<Listing> _listings = [];
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
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading map listings: $e');
      if (!mounted) return;
      setState(() {
        _listings = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Explorer la carte', style: FlexTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(9.34, 2.63),
              initialZoom: 7.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.flex.app',
              ),
              MarkerLayer(
                markers: _listings.map((l) => Marker(
                  point: LatLng(l.latitude, l.longitude),
                  width: 160,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _showListingPreview(l),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: l.isCertified ? FlexColors.certified : FlexColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('${l.prixParNuit.toInt()}k', style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600,
                            color: FlexColors.primary500,
                          )),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 12, right: 12,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2, color: FlexColors.primary500),
                ),
              ),
            ),
          Positioned(
            top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(FlexRadius.md),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  _LegendDot(color: FlexColors.certified, label: 'Certifié'),
                  const SizedBox(width: 12),
                  _LegendDot(color: FlexColors.warning, label: 'En attente'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showListingPreview(Listing listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    AdaptiveOverlay.show(
      context: context,
      isSidePanel: true,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FlexSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: FlexColors.neutral300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(listing.titre, style: FlexTextStyles.h3),
              const SizedBox(height: 8),
              Text('${listing.prixParNuit.toInt()} FCFA/nuit', style: FlexTextStyles.h2.copyWith(color: FlexColors.primary500)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/listing/${listing.id}', extra: listing);
                  },
                  child: const Text('Voir le détail'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
      ],
    );
  }
}
