import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Mes Favoris', style: FlexTextStyles.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
            ),
            const SizedBox(height: FlexSpacing.md),
            Text(
              'Aucun favori pour le moment',
              style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral500),
            ),
            const SizedBox(height: FlexSpacing.sm),
            Text(
              'Ajoutez des logements à vos favoris pour les retrouver ici.',
              style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
