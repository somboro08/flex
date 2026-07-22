import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../widgets/listing_card.dart';

class AllListingsScreen extends StatelessWidget {
  final String title;
  final List<Listing> listings;

  const AllListingsScreen({
    super.key, 
    required this.title, 
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: Text(title, style: FlexTextStyles.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: listings.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(FlexSpacing.md),
              itemCount: listings.length,
              separatorBuilder: (context, index) => const SizedBox(height: FlexSpacing.md),
              itemBuilder: (context, index) {
                return ListingCard(listing: listings[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
          ),
          const SizedBox(height: FlexSpacing.lg),
          Text(
            'Aucun logement trouvé',
            style: FlexTextStyles.h2.copyWith(
              color: isDark ? FlexColors.neutral300 : FlexColors.neutral700,
            ),
          ),
          const SizedBox(height: FlexSpacing.sm),
          Text(
            'Réessayez avec d\'autres critères ou une autre ville.',
            style: FlexTextStyles.body.copyWith(
              color: FlexColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
