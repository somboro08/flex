import 'package:flutter/material.dart';
import '../theme/flex_theme.dart';
import '../models/models.dart';
import 'flex_badge.dart';
import 'listing_detail_bottom_sheet.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/chat/chat_screen.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;

  const ListingCard({super.key, required this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap ?? () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ListingDetailBottomSheet(listing: listing),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(
            color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(FlexRadius.lg),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          size: 48,
                          color: isDark ? FlexColors.neutral600 : FlexColors.neutral300,
                        ),
                        Text(
                          listing.ville,
                          style: FlexTextStyles.caption.copyWith(
                            color: isDark ? FlexColors.neutral500 : FlexColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Certification badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: CertificationBadge(status: listing.certification),
                ),

                // Price
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(FlexRadius.full),
                    ),
                    child: Text(
                      '${_formatPrice(listing.prixParNuit)} FCFA/nuit',
                      style: FlexTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Message button
                Positioned(
                  bottom: 12,
                  right: 56,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            listing: listing,
                            initialMessage: 'Bonjour, je suis intéressé par votre logement "${listing.titre}". Est-il disponible ?',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: FlexColors.primary500,
                      ),
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: FlexColors.neutral600,
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(FlexSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.titre,
                    style: FlexTextStyles.h3.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: FlexColors.neutral400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${listing.quartier}, ${listing.ville}',
                        style: FlexTextStyles.caption.copyWith(
                          color: FlexColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FlexSpacing.sm),

                  // Equipements
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: listing.equipements.take(3).map((e) => _EquipChip(label: e)).toList(),
                  ),
                  const SizedBox(height: FlexSpacing.sm),

                  // Footer: rating + book button
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: FlexColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        listing.note.toStringAsFixed(1),
                        style: FlexTextStyles.label.copyWith(
                          color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                        ),
                      ),
                      Text(
                        ' (${listing.nombreAvis} avis)',
                        style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingConfirmationScreen(listing: listing),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Réserver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.toInt().toString();
  }
}

class _EquipChip extends StatelessWidget {
  final String label;
  const _EquipChip({required this.label});

  static const Map<String, IconData> _icons = {
    'WiFi': Icons.wifi_rounded,
    'Climatisation': Icons.ac_unit_rounded,
    'Ventilateur': Icons.air_rounded,
    'Parking': Icons.local_parking_rounded,
    'Eau courante': Icons.water_drop_rounded,
    'Eau chaude': Icons.hot_tub_rounded,
    'Cuisine': Icons.kitchen_rounded,
    'Petit-déjeuner': Icons.free_breakfast_rounded,
    'Jardin': Icons.park_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
        borderRadius: BorderRadius.circular(FlexRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_icons.containsKey(label))
            Icon(_icons[label]!, size: 12, color: FlexColors.primary500),
          if (_icons.containsKey(label)) const SizedBox(width: 4),
          Text(
            label,
            style: FlexTextStyles.caption.copyWith(
              color: isDark ? FlexColors.neutral300 : FlexColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
