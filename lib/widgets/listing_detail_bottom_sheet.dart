import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/flex_theme.dart';
import '../models/models.dart';
import 'flex_badge.dart';
import '../screens/booking/booking_confirmation_screen.dart';

class ListingDetailBottomSheet extends StatefulWidget {
  final Listing listing;

  const ListingDetailBottomSheet({super.key, required this.listing});

  @override
  State<ListingDetailBottomSheet> createState() => _ListingDetailBottomSheetState();
}

class _ListingDetailBottomSheetState extends State<ListingDetailBottomSheet> {
  final PageController _imageController = PageController();
  final PageController _mainPageController = PageController();
  int _currentMainPage = 0;

  @override
  void dispose() {
    _imageController.dispose();
    _mainPageController.dispose();
    super.dispose();
  }

  void _goToMap() {
    _mainPageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToDetails() {
    _mainPageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? FlexColors.neutral700 : FlexColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _mainPageController,
              onPageChanged: (index) {
                setState(() => _currentMainPage = index);
              },
              children: [
                _buildDetailsPage(isDark, size),
                _buildMapPage(isDark, size),
              ],
            ),
          ),

          // Bottom Bar (Sticky)
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildDetailsPage(bool isDark, Size size) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(isDark, size),
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listing.titre,
                            style: FlexTextStyles.h2.copyWith(
                              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: FlexColors.neutral400),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.listing.quartier}, ${widget.listing.ville}',
                                style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                              ),
                              const SizedBox(width: 8),
                              // Location toggle button
                              GestureDetector(
                                onTap: _goToMap,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: FlexColors.primary500.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.map_rounded,
                                    size: 16,
                                    color: FlexColors.primary500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildRatingBadge(),
                  ],
                ),

                const SizedBox(height: FlexSpacing.lg),
                CertificationBadge(status: widget.listing.certification),
                const SizedBox(height: FlexSpacing.lg),

                Row(
                  children: [
                    _buildInfoChip(Icons.door_front_door_outlined, '${widget.listing.nombreChambres} Chambres', isDark),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.person_outline_rounded, '2-4 Personnes', isDark),
                  ],
                ),

                const SizedBox(height: FlexSpacing.xl),
                Text(
                  'À propos du logement',
                  style: FlexTextStyles.h3.copyWith(
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                  ),
                ),
                const SizedBox(height: FlexSpacing.sm),
                Text(
                  widget.listing.description,
                  style: FlexTextStyles.body.copyWith(
                    color: isDark ? FlexColors.neutral400 : FlexColors.neutral600,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: FlexSpacing.xl),
                Text(
                  'Équipements inclus',
                  style: FlexTextStyles.h3.copyWith(
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                  ),
                ),
                const SizedBox(height: FlexSpacing.md),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.listing.equipements.map((e) => _buildEquipItem(e, isDark)).toList(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPage(bool isDark, Size size) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(isDark, size),
          Padding(
            padding: const EdgeInsets.all(FlexSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _goToDetails,
                      icon: const Icon(Icons.arrow_back_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Localisation',
                      style: FlexTextStyles.h2.copyWith(
                        color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.listing.quartier}, ${widget.listing.ville}',
                  style: FlexTextStyles.bodyLarge.copyWith(
                    color: FlexColors.primary500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: FlexSpacing.lg),
                
                // OpenStreetMap Container
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FlexRadius.lg),
                    border: Border.all(
                      color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(widget.listing.latitude, widget.listing.longitude),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.flex.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.listing.latitude, widget.listing.longitude),
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: FlexColors.primary500,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: FlexSpacing.xl),
                Text(
                  'Comment s\'y rendre ?',
                  style: FlexTextStyles.h3.copyWith(
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Le logement est situé à proximité de ${widget.listing.quartier}. Une fois votre réservation confirmée, vous recevrez l\'itinéraire exact et le contact de l\'hôte.',
                  style: FlexTextStyles.body.copyWith(
                    color: isDark ? FlexColors.neutral400 : FlexColors.neutral600,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(bool isDark, Size size) {
    final List<String> photos = widget.listing.photos.isEmpty 
        ? ['placeholder1', 'placeholder2', 'placeholder3'] 
        : widget.listing.photos;

    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _imageController,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDark ? FlexColors.neutral800 : FlexColors.neutral200,
                  borderRadius: BorderRadius.circular(FlexRadius.lg),
                ),
                child: Center(
                  child: Icon(
                    Icons.home_work_rounded,
                    size: 64,
                    color: isDark ? FlexColors.neutral700 : FlexColors.neutral300,
                  ),
                ),
              );
            },
          ),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _imageController,
                count: photos.length,
                effect: JumpingDotEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  jumpScale: .7,
                  verticalOffset: 15,
                  activeDotColor: FlexColors.primary500,
                  dotColor: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FlexColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FlexRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 18, color: FlexColors.warning),
          const SizedBox(width: 4),
          Text(
            widget.listing.note.toString(),
            style: FlexTextStyles.label.copyWith(
              color: FlexColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.md),
        border: Border.all(
          color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FlexColors.primary500),
          const SizedBox(width: 8),
          Text(
            label,
            style: FlexTextStyles.label.copyWith(
              color: isDark ? FlexColors.neutral300 : FlexColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipItem(String label, bool isDark) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - (FlexSpacing.lg * 2) - 12) / 2,
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: FlexColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: FlexTextStyles.body.copyWith(
                color: isDark ? FlexColors.neutral400 : FlexColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.listing.prixParNuit.toInt()} FCFA',
                  style: FlexTextStyles.h3.copyWith(
                    color: FlexColors.primary500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'par nuit',
                  style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                ),
              ],
            ),
            const SizedBox(width: FlexSpacing.xl),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmationScreen(listing: widget.listing),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlexColors.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Réserver maintenant', style: FlexTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
