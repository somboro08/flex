import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../models/models.dart';
import '../../models/rental_models.dart';
import '../../repositories/listing_repository.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/search_screen.dart';
import '../../screens/home/map_screen.dart';
import '../../screens/home/notification_screen.dart';
import '../../screens/home/category_detail_screen.dart';
import '../../screens/home/budget_search_screen.dart';
import '../../screens/booking/my_bookings_screen.dart';
import '../../screens/booking/booking_confirmation_screen.dart';
import '../../screens/listing/listing_detail_screen.dart';
import '../../screens/listing/all_listings_screen.dart';
import '../../screens/listing/create_listing_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/favorites_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/identity_verification_screen.dart';
import '../../screens/profile/support_screen.dart';
import '../../screens/hote/hote_dashboard_screen.dart';
import '../../screens/hote/hote_rentals_screen.dart';
import '../../screens/hote/hote_visit_requests_screen.dart';
import '../../screens/locataire/locataire_rentals_screen.dart';
import '../../screens/locataire/advance_payment_screen.dart';
import '../../screens/locataire/refund_request_screen.dart';
import '../../screens/locataire/renew_booking_screen.dart';
import '../../screens/chat/conversations_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/auth_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthService authService) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) async {
      final location = state.matchedLocation;
      if (location == '/onboarding' || location == '/auth') return null;
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_done') ?? false;
      if (!onboardingDone) return '/onboarding';
      if (!authService.isLoggedIn) return '/auth';
      return null;
    },
    routes: [
      // ── Auth / Onboarding ────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // ── Main Shell (primary destinations) ───────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return NoTransitionPage(child: SearchScreen(initialQuery: query));
            },
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(child: MyBookingsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: '/conversations',
            pageBuilder: (context, state) => const NoTransitionPage(child: ConversationsScreen()),
          ),
        ],
      ),

      // ── Listing details & booking floor ──────────────────
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Listing) return ListingDetailScreen(listing: extra);
          return _ListingLoadGate(
            listingId: state.pathParameters['id'] ?? '',
            builder: (context, listing) => ListingDetailScreen(listing: listing),
          );
        },
      ),
      GoRoute(
        path: '/book/:listingId',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Listing) return BookingConfirmationScreen(listing: extra);
          return _ListingLoadGate(
            listingId: state.pathParameters['listingId'] ?? '',
            builder: (context, listing) => BookingConfirmationScreen(listing: listing),
          );
        },
      ),
      GoRoute(
        path: '/chat/:recipientId',
        builder: (context, state) {
          final extra = state.extra;
          final recipientId = state.pathParameters['recipientId'] ?? '';
          if (extra is Listing) {
            return ChatScreen(listing: extra, recipientId: recipientId);
          }
          if (extra is Map && extra['listing'] is Listing) {
            return ChatScreen(
              listing: extra['listing'] as Listing,
              recipientId: recipientId,
              initialMessage: extra['initialMessage'] as String? ?? '',
            );
          }
          return const _ChatUnavailable();
        },
      ),

      // ── Map & Notifications ──────────────────────────────
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // ── Categories & listings ────────────────────────────
      GoRoute(
        path: '/category/:label',
        builder: (context, state) => CategoryDetailScreen(
          category: state.pathParameters['label'] ?? '',
        ),
      ),
      GoRoute(
        path: '/budget-search',
        builder: (context, state) => const BudgetSearchScreen(),
      ),
      GoRoute(
        path: '/all-listings',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return AllListingsScreen(
              title: extra['title'] as String? ?? 'Logements',
              listings: (extra['listings'] as List?)?.cast<Listing>() ?? const [],
            );
          }
          return const AllListingsScreen(title: 'Logements', listings: []);
        },
      ),
      GoRoute(
        path: '/create-listing',
        builder: (context, state) => const CreateListingScreen(),
      ),

      // ── Profile sub-screens ──────────────────────────────
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/identity-verification',
        builder: (context, state) => const IdentityVerificationScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),

      // ── Hôte screens ────────────────────────────────────
      GoRoute(
        path: '/hote-dashboard',
        builder: (context, state) => const HoteDashboardScreen(),
      ),
      GoRoute(
        path: '/hote-rentals',
        builder: (context, state) => const HoteRentalsScreen(),
      ),
      GoRoute(
        path: '/hote-visits',
        builder: (context, state) => const HoteVisitRequestsScreen(),
      ),

      // ── Locataire screens ────────────────────────────────
      GoRoute(
        path: '/locataire-rentals',
        builder: (context, state) => const LocataireRentalsScreen(),
      ),
      GoRoute(
        path: '/advance-payment',
        builder: (context, state) {
          final extra = state.extra;
          return extra is MonthlyRental
              ? AdvancePaymentScreen(rental: extra)
              : const AdvancePaymentScreen();
        },
      ),
      GoRoute(
        path: '/refund-request',
        builder: (context, state) {
          final extra = state.extra;
          return extra is MonthlyRental
              ? RefundRequestScreen(rental: extra)
              : const RefundRequestScreen();
        },
      ),
      GoRoute(
        path: '/renew-booking',
        builder: (context, state) {
          final extra = state.extra;
          return extra is MonthlyRental
              ? RenewBookingScreen(rental: extra)
              : const RenewBookingScreen();
        },
      ),
    ],
  );
}

// ─────────────────────────────────────────────
//  Deep-link fallback: loads a Listing by ID
//  when a route is opened without an extra.
// ─────────────────────────────────────────────
class _ListingLoadGate extends StatefulWidget {
  final String listingId;
  final Widget Function(BuildContext context, Listing listing) builder;

  const _ListingLoadGate({required this.listingId, required this.builder});

  @override
  State<_ListingLoadGate> createState() => _ListingLoadGateState();
}

class _ListingLoadGateState extends State<_ListingLoadGate> {
  late final Future<Listing?> _future =
      ListingRepository().getListingById(widget.listingId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Listing?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final listing = snapshot.data;
        if (listing != null) return widget.builder(context, listing);
        return const Scaffold(
          appBar: null,
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Logement introuvable'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatUnavailable extends StatelessWidget {
  const _ChatUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Text('Cette conversation est indisponible.'),
      ),
    );
  }
}