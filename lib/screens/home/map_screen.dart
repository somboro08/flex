import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<_MapListing> _listings = [
    _MapListing('Chambre calme Parakou', 5000, 9.337, 2.628, CertificationStatus.certified),
    _MapListing('Studio meublé Cotonou', 15000, 6.365, 2.420, CertificationStatus.certified),
    _MapListing('Villa Ouidah', 35000, 6.360, 2.086, CertificationStatus.certified),
    _MapListing('Chambre économique', 5000, 9.340, 2.630, CertificationStatus.pending),
  ];

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
                  point: LatLng(l.lat, l.lng),
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
                              color: l.cert == CertificationStatus.certified ? FlexColors.certified : FlexColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('${l.prix}k', style: TextStyle(
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

  void _showListingPreview(_MapListing listing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(FlexSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: FlexColors.neutral300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(listing.titre, style: FlexTextStyles.h3),
            const SizedBox(height: 8),
            Text('${listing.prix} FCFA/nuit', style: FlexTextStyles.h2.copyWith(color: FlexColors.primary500)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voir le détail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapListing {
  final String titre; final int prix; final double lat; final double lng; final CertificationStatus cert;
  _MapListing(this.titre, this.prix, this.lat, this.lng, this.cert);
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
