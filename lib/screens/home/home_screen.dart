import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/flex_theme.dart';
import '../../theme/theme_provider.dart';
import '../../models/models.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/flex_badge.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import '../profile/profile_screen.dart';
import '../listing/all_listings_screen.dart';
import '../booking/my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  String _selectedVille = 'Parakou';

  final List<String> _villes = [
    'Parakou', 'Cotonou', 'Abomey', 'Natitingou', 'Bohicon', 'Porto-Novo',
  ];

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
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: FlexColors.primary500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/flex.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
               
              ],
            ),
            actions: [
              // Theme toggle
              IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: FlexColors.neutral500,
                ),
              ),
              // Notifications
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
                icon: const Icon(Icons.notifications_outlined, color: FlexColors.neutral500),
              ),
              // Profile
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: FlexColors.primary100,
                    child: Text(
                      'G',
                      style: FlexTextStyles.label.copyWith(color: FlexColors.primary600),
                    ),
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

                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
                      borderRadius: BorderRadius.circular(FlexRadius.lg),
                      border: Border.all(
                        color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: FlexColors.neutral400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Rechercher une ville, un quartier...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              hintStyle: FlexTextStyles.body.copyWith(
                                color: FlexColors.neutral400,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: FlexColors.primary500,
                            borderRadius: BorderRadius.circular(FlexRadius.md),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FlexSpacing.md),

                  // City filter chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _villes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final isSelected = _villes[i] == _selectedVille;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedVille = _villes[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? FlexColors.primary500
                                  : isDark ? FlexColors.neutral800 : FlexColors.neutral0,
                              borderRadius: BorderRadius.circular(FlexRadius.full),
                              border: Border.all(
                                color: isSelected
                                    ? FlexColors.primary500
                                    : isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _villes[i],
                              style: FlexTextStyles.label.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : isDark ? FlexColors.neutral300 : FlexColors.neutral600,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: FlexSpacing.lg),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(FlexSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [FlexColors.primary500, FlexColors.primary600],
                      ),
                      borderRadius: BorderRadius.circular(FlexRadius.lg),
                    ),
                    child: Row(
                      children: [
                        _StatItem(value: '50+', label: 'Logements\ncertifiés'),
                        _divider(),
                        _StatItem(value: '3', label: 'Agents\nterrain'),
                        _divider(),
                        _StatItem(value: '4.7★', label: 'Note\nmoyenne'),
                      ],
                    ),
                  ),
                  const SizedBox(height: FlexSpacing.lg),

                  // Section title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Disponibles à $_selectedVille',
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
                                title: 'Disponibles à $_selectedVille',
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
                  child: ListingCard(listing: _featuredListings[i]),
                ),
                childCount: _featuredListings.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: FlexSpacing.xl)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 0.5,
    height: 40,
    color: Colors.white30,
    margin: const EdgeInsets.symmetric(horizontal: 16),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: FlexTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: FlexTextStyles.caption.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
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
