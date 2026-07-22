import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../widgets/listing_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Mock favorites
  final List<Listing> _favorites = [
    Listing(
      id: 'f1', hoteId: 'h1', titre: 'Chambre calme Parakou',
      description: 'Chambre propre avec ventilateur.', ville: 'Parakou',
      quartier: 'Zongo', adresse: 'Rue des Artisans', latitude: 9.337,
      longitude: 2.628, prixParNuit: 5000, photos: [],
      equipements: ['Ventilateur', 'WiFi'], certification: CertificationStatus.certified,
      note: 4.8, nombreAvis: 23, createdAt: DateTime.now(),
    ),
    Listing(
      id: 'f2', hoteId: 'h2', titre: 'Studio meublé Cotonou',
      description: 'Studio indépendant.', ville: 'Cotonou',
      quartier: 'Fidjrossé', adresse: 'Route des Pêches', latitude: 6.35,
      longitude: 2.38, prixParNuit: 12000, photos: [],
      equipements: ['WiFi', 'Climatisation'], certification: CertificationStatus.certified,
      note: 4.6, nombreAvis: 15, createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: Text('Mes favoris (${_favorites.length})', style: FlexTextStyles.h3),
        leading: const BackButton(),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 64, color: FlexColors.neutral300),
                  const SizedBox(height: 16),
                  Text('Aucun favori', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
                  const SizedBox(height: 8),
                  Text('Ajoutez des logements à vos favoris', style: FlexTextStyles.body.copyWith(color: FlexColors.neutral400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(FlexSpacing.md),
              itemCount: _favorites.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListingCard(listing: _favorites[i]),
              ),
            ),
    );
  }
}
