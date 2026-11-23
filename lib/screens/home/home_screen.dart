import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/flex_theme.dart';
import '../../theme/theme_provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../services/cache_service.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/favorite_repository.dart';
import '../../widgets/listing_card.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import '../../shared/widgets/adaptive_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  Set<String> _favorites = {};
  List<Listing> _recentlyViewed = [];
  int _placeholderIndex = 0;

  final _listingRepo = ListingRepository();
  final _favRepo = FavoriteRepository();
  Map<String, int> _stats = {};

  final _placeholders = ['Ville, quartier...', 'Budget ?', 'Catégorie ?', 'WiFi, parking...'];

  final List<_CategoryData> _categories = [
    _CategoryData('Location', Icons.home_rounded, '120+', 'location', imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('Cohabitation', Icons.people_rounded, '45+', 'cohabitation', imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('Court séjour', Icons.flash_on_rounded, '80+', 'court_sejour', imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('~ 10 000 FCFA', Icons.monetization_on_rounded, '200+', 'petit_budget', imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('Villa', Icons.villa_rounded, '25+', 'villa', imageUrl: 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('Espace', Icons.event_rounded, '15+', 'espace', imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('Club', Icons.nightlife_rounded, '10+', 'club', imageUrl: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=500&auto=format&fit=crop&q=80'),
    _CategoryData('Mon budget', Icons.calculate_rounded, '💰', 'budget', isBudget: true, imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=500&auto=format&fit=crop&q=80'),
  ];

  List<Listing> _featuredListings = [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _cyclePlaceholder();
  }

  void _cyclePlaceholder() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;
      setState(() => _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length);
    }
  }

  Future<void> _refresh() async {
    final cache = CacheService();
    try {
      final listings = await _listingRepo.getListings();
      await cache.saveListings(listings.map((l) => l.toJson()).toList());

      Map<String, dynamic>? stats;
      try {
        stats = await _listingRepo.getStats();
      } catch (e) {
        debugPrint('Error fetching stats: $e');
      }

      Set<String> favs;
      if (AuthService().isLoggedIn) {
        try {
          favs = (await _favRepo.getFavorites()).map((l) => l.id).toSet();
        } catch (e) {
          debugPrint('Error fetching favorites: $e');
          favs = {};
        }
      } else {
        favs = (await StorageService.getFavorites()).toSet();
      }

      final recentIds = await StorageService.getRecentViews();
      if (!mounted) return;
      setState(() {
        _featuredListings = listings;
        _favorites = favs;
        _recentlyViewed = listings.where((l) => recentIds.contains(l.id)).toList();
        _stats = _parseStats(stats);
      });
    } catch (e) {
      debugPrint('Error loading listings — trying cache: $e');
      final cached = await cache.getListings();
      if (cached != null && mounted) {
        final listings = cached.map((j) => Listing.fromJson(j as Map<String, dynamic>)).toList();
        final recentIds = await StorageService.getRecentViews();
        setState(() {
          _featuredListings = listings;
          _recentlyViewed = listings.where((l) => recentIds.contains(l.id)).toList();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📴 Mode hors-ligne — données du cache affichées'),
              duration: Duration(seconds: 3),
              backgroundColor: FlexColors.primary500,
            ),
          );
        }
      }
    }
  }

  Map<String, int> _parseStats(Map<String, dynamic>? stats) {
    if (stats == null) return {};
    final byType = stats['byType'];
    if (byType is Map) {
      return byType.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    return {};
  }

  String _categoryCount(String route) {
    if (_stats.isEmpty) return '';
    final total = _stats.values.fold<int>(0, (a, b) => a + b);
    final chambreStudio = (_stats['chambre'] ?? 0) + (_stats['studio'] ?? 0);
    switch (route) {
      case 'location': return '$total+';
      case 'cohabitation': return '${_stats['cohabitation'] ?? 0}+';
      case 'court_sejour': return '$chambreStudio+';
      case 'petit_budget': return '$chambreStudio+';
      case 'villa': return '${_stats['villa'] ?? 0}+';
      case 'espace': return '${_stats['espace'] ?? 0}+';
      case 'club': return '${_stats['club'] ?? 0}+';
      default: return '$total+';
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      if (AuthService().isLoggedIn) {
        if (_favorites.contains(id)) {
          await _favRepo.removeFavorite(id);
        } else {
          await _favRepo.addFavorite(id);
        }
      } else {
        await StorageService.toggleFavorite(id);
      }
      await _refresh();
    } catch (e) {
      debugPrint('Favorite toggle error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de modifier les favoris')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final auth = AuthService();
    final isLoggedIn = auth.isLoggedIn;
    final initial = (isLoggedIn && auth.currentUser != null && auth.currentUser!.prenom.isNotEmpty)
        ? auth.currentUser!.prenom[0].toUpperCase()
        : 'G';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: FlexColors.primary500,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  // Logo
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: FlexColors.primary500,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/flex.svg',
                        width: 16, height: 16,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Search bar
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/search'),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? FlexColors.neutral800 : FlexColors.neutral100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, size: 14, color: FlexColors.neutral400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                switchInCurve: Curves.easeOutCubic,
                                transitionBuilder: (child, animation) {
                                  final slide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation);
                                  final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                                  return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
                                },
                                child: Text(
                                  _placeholders[_placeholderIndex],
                                  key: ValueKey(_placeholderIndex),
                                  style: const TextStyle(fontSize: 12, color: FlexColors.neutral400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Changer de thème',
                  onPressed: themeProvider.toggleTheme,
                  icon: Icon(
                    themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: FlexColors.neutral500, size: 20,
                  ),
                ),
                IconButton(
                  tooltip: 'Carte',
                  onPressed: () => context.push('/map'),
                  icon: const Icon(Icons.map_outlined, color: FlexColors.neutral500, size: 20),
                ),
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_outlined, color: FlexColors.neutral500, size: 20),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: 'Profil',
                    child: GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: FlexColors.primary100,
                        child: Text(initial, style: const TextStyle(fontSize: 11, color: FlexColors.primary600, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Content ────────────────────────────────────
            SliverToBoxAdapter(
              child: AdaptiveContentContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FlexSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text(
                        'Où allez-vous ?',
                        style: FlexTextStyles.h2.copyWith(
                          color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                        ),
                      ),
                      Text(
                        'Trouvez un logement certifié Flex',
                        style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                      ),

                      // Login CTA for guests
                      if (!isLoggedIn) ...[
                        const SizedBox(height: FlexSpacing.md),
                        GestureDetector(
                          onTap: () => context.go('/auth'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FlexColors.primary500.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: FlexColors.primary500.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.login_rounded, size: 18, color: FlexColors.primary500),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Connectez-vous pour réserver et gérer vos favoris',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: FlexColors.primary500),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: FlexColors.primary500),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: FlexSpacing.md),

                      // Category cards
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, i) => _CategoryCard(
                            category: _categories[i],
                            countOverride: _categoryCount(_categories[i].route),
                            isDark: isDark,
                            onTap: () {
                              if (_categories[i].route == 'budget') {
                                context.push('/budget-search');
                              } else {
                                context.push(
                                  '/category/${Uri.encodeComponent(_categories[i].label)}',
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: FlexSpacing.lg),

                      // Recently viewed
                      if (_recentlyViewed.isNotEmpty) ...[
                        Text(
                          'Derniers vus',
                          style: FlexTextStyles.h3.copyWith(
                            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                          ),
                        ),
                        const SizedBox(height: FlexSpacing.sm),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recentlyViewed.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final l = _recentlyViewed[i];
                              final isFav = _favorites.contains(l.id);
                              return SizedBox(
                                width: 180,
                                child: GestureDetector(
                                  onTap: () => context.push(
                                    '/listing/${l.id}',
                                    extra: l,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? FlexColors.neutral800 : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                                  image: l.photos.isNotEmpty
                                                      ? DecorationImage(image: NetworkImage(l.photos.first), fit: BoxFit.cover)
                                                      : null,
                                                ),
                                                child: l.photos.isEmpty
                                                    ? const Center(child: Icon(Icons.home_rounded, size: 32))
                                                    : null,
                                              ),
                                              Positioned(
                                                top: 6, right: 6,
                                                child: GestureDetector(
                                                  onTap: () => _toggleFavorite(l.id),
                                                  child: Container(
                                                    width: 28, height: 28,
                                                    decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                                                    child: Icon(
                                                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                      size: 14, color: isFav ? Colors.red : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(l.titre,
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text('${l.prixParNuit.toInt()} FCFA',
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: FlexColors.primary500)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: FlexSpacing.lg),
                      ],

                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Populaires',
                            style: FlexTextStyles.h3.copyWith(
                              color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(
                                '/all-listings',
                                extra: {
                                  'title': 'Logements disponibles',
                                  'listings': _featuredListings,
                                },
                              );
                            },
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Adaptive listings grid ──────────────────────
            SliverToBoxAdapter(
              child: AdaptiveContentContainer(
                child: AdaptiveGrid<Listing>(
                  items: _featuredListings,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mobileCrossAxisCount: 1,
                  tabletCrossAxisCount: 2,
                  desktopCrossAxisCount: 3,
                  largeDesktopCrossAxisCount: 4,
                  mainAxisSpacing: FlexSpacing.md,
                  crossAxisSpacing: FlexSpacing.md,
                  childAspectRatio: context.isMobile ? 0.95 : 0.82,
                  itemBuilder: (context, listing, i) => ListingCard(
                    listing: listing,
                    isFavorite: _favorites.contains(listing.id),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: FlexSpacing.xl)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  Internal data / widgets
// ─────────────────────────────────────────────

class _CategoryData {
  final String label;
  final IconData icon;
  final String count;
  final String route;
  final bool isBudget;
  final String imageUrl;

  const _CategoryData(
    this.label,
    this.icon,
    this.count,
    this.route, {
    this.isBudget = false,
    required this.imageUrl,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData category;
  final bool isDark;
  final VoidCallback onTap;
  final String? countOverride;

  const _CategoryCard({
    required this.category,
    required this.isDark,
    required this.onTap,
    this.countOverride,
  });

  @override
  Widget build(BuildContext context) {
    const w = 130.0;
    const h = 210.0;
    final b = category.isBudget;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w, height: h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(
            color: b ? FlexColors.primary500 : (isDark ? FlexColors.neutral700 : FlexColors.neutral200),
          ),
          boxShadow: [
            BoxShadow(
              color: (b ? FlexColors.primary500 : Colors.black).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                category.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: FlexColors.primary500.withOpacity(0.2)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: b
                        ? [FlexColors.primary500.withOpacity(0.85), FlexColors.primary600.withOpacity(0.95)]
                        : [Colors.black.withOpacity(0.25), Colors.black.withOpacity(0.82)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: GeometricBackgroundPainter(
                  color: Colors.white,
                  opacity: b ? 0.14 : 0.08,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: b ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
                    ),
                    child: Icon(category.icon, size: 20, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    (countOverride ?? category.count).isEmpty ? '—' : (countOverride ?? category.count),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
                  ),
                  if (b) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Tapez →', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeometricBackgroundPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const GeometricBackgroundPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant GeometricBackgroundPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
