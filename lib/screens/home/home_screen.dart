import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/flex_theme.dart';
import '../../theme/theme_provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../widgets/listing_card.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'category_detail_screen.dart';
import 'budget_search_screen.dart';
import '../../utils/rental_utils.dart';
import '../profile/profile_screen.dart';
import '../listing/all_listings_screen.dart';
import '../listing/listing_detail_screen.dart';
import '../booking/my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  Set<String> _favorites = {};
  List<Listing> _recentlyViewed = [];
  int _placeholderIndex = 0;

  final _placeholders = ['Ville, quartier...', 'Budget ?', 'Catégorie ?', 'WiFi, parking...'];

  final List<_CategoryData> _categories = [
    _CategoryData('Location', Icons.home_rounded, '120+', 'location'),
    _CategoryData('Cohabitation', Icons.people_rounded, '45+', 'cohabitation'),
    _CategoryData('Court séjour', Icons.flash_on_rounded, '80+', 'court_sejour'),
    _CategoryData('~ 10 000 FCFA', Icons.monetization_on_rounded, '200+', 'petit_budget'),
    _CategoryData('Villa', Icons.villa_rounded, '25+', 'villa'),
    _CategoryData('Espace', Icons.event_rounded, '15+', 'espace'),
    _CategoryData('Club', Icons.nightlife_rounded, '10+', 'club'),
    _CategoryData('Mon budget', Icons.calculate_rounded, '💰', 'budget', isBudget: true),
  ];

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
    final favs = await StorageService.getFavorites();
    final recentIds = await StorageService.getRecentViews();
    setState(() {
      _favorites = favs.toSet();
      _recentlyViewed = _featuredListings.where((l) => recentIds.contains(l.id)).toList();
    });
  }

  // Mock data
  final List<Listing> _featuredListings = [
    Listing(
      id: '1',
      hoteId: 'h1',
      titre: 'Chambre calme chez Madame Akobi',
      description: 'Chambre propre avec ventilateur, idéale pour les travailleurs de passage.',
      ville: 'Parakou',
      quartier: 'Zongo',
      adresse: 'Rue des Artisans, Zongo',
      latitude: 9.337,
      longitude: 2.628,
      prixParNuit: 5000,
      photos: [],
      equipements: ['Ventilateur', 'Eau courante', 'WiFi', 'Parking'],
      certification: CertificationStatus.certified,
      note: 4.8,
      nombreAvis: 23,
      createdAt: DateTime.now(),
    ),
    Listing(
      id: '2',
      hoteId: 'h2',
      titre: 'Studio meublé Centre-ville',
      description: 'Studio indépendant avec salle de bain privée et cuisine équipée.',
      ville: 'Parakou',
      quartier: 'Kpébié',
      adresse: 'Avenue de la Liberté, Kpébié',
      latitude: 9.341,
      longitude: 2.624,
      prixParNuit: 8500,
      photos: [],
      equipements: ['Climatisation', 'Eau chaude', 'WiFi', 'Cuisine'],
      certification: CertificationStatus.certified,
      note: 4.6,
      nombreAvis: 11,
      createdAt: DateTime.now(),
    ),
    Listing(
      id: '3',
      hoteId: 'h3',
      titre: 'Chambre familiale avec jardin',
      description: 'Grande chambre dans une maison familiale sécurisée avec jardin.',
      ville: 'Parakou',
      quartier: 'Alaga',
      adresse: 'Quartier Alaga, Parakou',
      latitude: 9.330,
      longitude: 2.631,
      prixParNuit: 6500,
      photos: [],
      equipements: ['Ventilateur', 'Jardin', 'Parking', 'Petit-déjeuner'],
      certification: CertificationStatus.pending,
      note: 4.4,
      nombreAvis: 7,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeBody(isDark),
          const SearchScreen(),
          const MyBookingsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _FlexBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  Widget _buildHomeBody(bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: FlexColors.primary500,
        child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
            title: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: FlexColors.primary500,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/flex.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
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
                          Icon(Icons.search_rounded, size: 14, color: FlexColors.neutral400),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Stack(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
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
                                TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(fontSize: 12, color: Colors.transparent),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (v) {
                                    if (v.trim().isNotEmpty) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => SearchScreen(initialQuery: v.trim()),
                                      ));
                                    }
                                  },
                                ),
                              ],
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
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: FlexColors.neutral500, size: 20,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                icon: const Icon(Icons.notifications_outlined, color: FlexColors.neutral500, size: 20),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: FlexColors.primary100,
                    child: Text('G', style: TextStyle(fontSize: 11, color: FlexColors.primary600, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(FlexSpacing.md),
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
                  const SizedBox(height: FlexSpacing.md),

                  // Category cards 9:16 horizontal scroll
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _CategoryCard(
                        category: _categories[i],
                        isDark: isDark,
                        onTap: () {
                          if (_categories[i].route == 'budget') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetSearchScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CategoryDetailScreen(category: _categories[i].label),
                            ));
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: FlexSpacing.lg),

                  // Derniers vus
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
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(listing: l),
                              )),
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
                                            ),
                                            child: const Center(child: Icon(Icons.home_rounded, size: 32)),
                                          ),
                                          Positioned(
                                            top: 6, right: 6,
                                            child: GestureDetector(
                                              onTap: () async {
                                                await StorageService.toggleFavorite(l.id);
                                                _refresh();
                                              },
                                              child: Container(
                                                width: 28, height: 28,
                                                decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                                                child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 14, color: isFav ? Colors.red : Colors.white),
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
                                          Text(l.titre, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text('${l.prixParNuit.toInt()} FCFA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: FlexColors.primary500)),
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

                  // Section title
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllListingsScreen(
                                title: 'Logements disponibles',
                                listings: _featuredListings,
                              ),
                            ),
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

          // Listings
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: FlexSpacing.md),
                  child: ListingCard(
                    listing: _featuredListings[i],
                    isFavorite: _favorites.contains(_featuredListings[i].id),
                  ),
                ),
                childCount: _featuredListings.length,
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

class _CategoryData {
  final String label; final IconData icon; final String count; final String route; final bool isBudget;
  const _CategoryData(this.label, this.icon, this.count, this.route, {this.isBudget = false});
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData category; final bool isDark; final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = 130.0; final h = 210.0; final b = category.isBudget;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w, height: h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          gradient: b ? const LinearGradient(colors: [FlexColors.primary500, FlexColors.primary600]) : null,
          color: b ? null : (isDark ? FlexColors.neutral800 : Colors.white),
          border: !b ? Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200) : null,
          boxShadow: b ? [BoxShadow(color: FlexColors.primary500.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: b ? null : GeometricBackgroundPainter(color: FlexColors.primary500, opacity: 0.04))),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: b ? Colors.white.withValues(alpha: 0.15) : FlexColors.primary500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(category.icon, size: 20, color: b ? Colors.white : FlexColors.primary500),
                  ),
                  const Spacer(),
                  Text(category.count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: b ? Colors.white : (isDark ? FlexColors.neutral0 : FlexColors.neutral800))),
                  const SizedBox(height: 4),
                  Text(category.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: b ? Colors.white70 : (isDark ? FlexColors.neutral400 : FlexColors.neutral600))),
                  if (b) ...[const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Tapez →', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)))],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlexBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _FlexBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
        border: Border(
          top: BorderSide(
            color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_rounded),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
