import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'adaptive_scaffold.dart';

/// The primary application shell. Wraps the ShellRoute child (page body)
/// and provides the AdaptiveScaffold (Sidebar / NavRail / BottomNav).
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _destinations = [
    AdaptiveNavigationItem(
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: '/home',
      index: 0,
    ),
    AdaptiveNavigationItem(
      label: 'Recherche',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search_rounded,
      route: '/search',
      index: 1,
    ),
    AdaptiveNavigationItem(
      label: 'Réservations',
      icon: Icons.bookmark_outline_rounded,
      selectedIcon: Icons.bookmark_rounded,
      route: '/bookings',
      index: 2,
    ),
    AdaptiveNavigationItem(
      label: 'Messagerie',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
      route: '/conversations',
      index: 3,
    ),
    AdaptiveNavigationItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      route: '/profile',
      index: 4,
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/bookings')) return 2;
    if (location.startsWith('/conversations')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final route = _destinations[index].route;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return AdaptiveScaffold(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) => _onDestinationSelected(context, i),
      destinations: _destinations,
      body: child,
    );
  }
}
