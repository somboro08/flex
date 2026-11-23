import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/favorite_repository.dart';
import '../../widgets/listing_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favRepo = FavoriteRepository();
  List<Listing> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _favRepo.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Favorites error: $e');
      if (!mounted) return;
      setState(() {
        _favorites = [];
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
        title: Text('Mes favoris (${_favorites.length})', style: FlexTextStyles.h3),
        leading: const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FlexColors.primary500))
          : _favorites.isEmpty
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
              : RefreshIndicator(
                  onRefresh: _load,
                  color: FlexColors.primary500,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(FlexSpacing.md),
                    itemCount: _favorites.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListingCard(listing: _favorites[i], isFavorite: true),
                    ),
                  ),
                ),
    );
  }
}
