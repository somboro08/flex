import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/booking_repository.dart';
import '../../shared/widgets/adaptive_overlay.dart';
import '../../shared/widgets/adaptive_dialog_content.dart';
import '../../repositories/listing_repository.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import '../payment/payment_screen.dart';
import 'review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedFilter = 0;
  final _filters = ['Tout', 'À venir', 'En cours', 'Terminé', 'Annulé'];
  bool _isLoading = true;
  final _bookingRepo = BookingRepository();
  final _listingRepo = ListingRepository();
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final list = await _bookingRepo.getMyBookings();
      if (mounted) {
        setState(() {
          _bookings = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await AdaptiveOverlay.show<bool>(
      context: context,
      child: AdaptiveDialogContent(
        title: 'Annuler la réservation',
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FlexColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.white)),
          ),
        ],
        child: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
      ),
    );

    if (confirm != true) return;

    try {
      final ok = await _bookingRepo.cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Réservation annulée.' : 'Erreur lors de l\'annulation.'),
            backgroundColor: ok ? FlexColors.success : FlexColors.error,
          ),
        );
        if (ok) _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: FlexColors.error),
        );
      }
    }
  }

  Future<void> _openReviewScreen(Booking booking) async {
    try {
      final listing = await _listingRepo.getListingById(booking.listingId);
      if (listing != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReviewScreen(listing: listing, booking: booking)),
        );
        _loadBookings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logement introuvable pour laisser un avis.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  List<Booking> get _filteredBookings {
    switch (_selectedFilter) {
      case 1: return _bookings.where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.confirmed).toList();
      case 2: return _bookings.where((b) => b.status == BookingStatus.checkedIn).toList();
      case 3: return _bookings.where((b) => b.status == BookingStatus.completed).toList();
      case 4: return _bookings.where((b) => b.status == BookingStatus.cancelled).toList();
      default: return _bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Mes Réservations', style: FlexTextStyles.h3),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AdaptiveContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _selectedFilter == i;
                  return ChoiceChip(
                    label: Text(_filters[i]),
                    selected: selected,
                    selectedColor: FlexColors.primary500,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : (isDark ? FlexColors.neutral300 : FlexColors.neutral700),
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = i);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 64, color: FlexColors.neutral300),
                              const SizedBox(height: 16),
                              Text('Aucune réservation', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          child: _buildAdaptiveBookingsList(isDark),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveBookingsList(bool isDark) {
    final bookings = _filteredBookings;

    // On desktop, show in a 2-column grid
    if (context.isDesktop || context.isTablet) {
      final colCount = context.isDesktop ? 2 : 1;
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: colCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _BookingCard(
          booking: bookings[i],
          isDark: isDark,
          onCancel: () => _cancelBooking(bookings[i].id),
          onReview: () => _openReviewScreen(bookings[i]),
        ),
      );
    }

    // Mobile: single column list
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: bookings.length,
      itemBuilder: (_, i) => _BookingCard(
        booking: bookings[i],
        isDark: isDark,
        onCancel: () => _cancelBooking(bookings[i].id),
        onReview: () => _openReviewScreen(bookings[i]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isDark;
  final VoidCallback onCancel;
  final VoidCallback onReview;

  const _BookingCard({
    required this.booking,
    required this.isDark,
    required this.onCancel,
    required this.onReview,
  });

  String _statusLabel() {
    switch (booking.status) {
      case BookingStatus.confirmed: return 'Confirmée';
      case BookingStatus.pending: return 'En attente';
      case BookingStatus.checkedIn: return 'En cours';
      case BookingStatus.completed: return 'Terminée';
      case BookingStatus.cancelled: return 'Annulée';
    }
  }

  Color _statusColor() {
    switch (booking.status) {
      case BookingStatus.confirmed: return FlexColors.success;
      case BookingStatus.pending: return FlexColors.warning;
      case BookingStatus.checkedIn: return FlexColors.info;
      case BookingStatus.completed: return FlexColors.neutral400;
      case BookingStatus.cancelled: return FlexColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(FlexRadius.full),
                ),
                child: Text(_statusLabel(), style: FlexTextStyles.caption.copyWith(
                  color: _statusColor(), fontWeight: FontWeight.w600,
                )),
              ),
              const Spacer(),
              Text('${booking.montantTotal.toInt()} FCFA',
                  style: FlexTextStyles.h3.copyWith(color: FlexColors.primary500)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: FlexColors.neutral100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_rounded, size: 20, color: FlexColors.neutral400),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Réservation #${booking.id.toUpperCase()}',
                        style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.dateArrivee.day}/${booking.dateArrivee.month}/${booking.dateArrivee.year}'
                      ' → ${booking.dateDepart.day}/${booking.dateDepart.month}/${booking.dateDepart.year}',
                      style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                    ),
                    Text('${booking.nombreNuits} nuits',
                        style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                  ],
                ),
              ),
            ],
          ),
          if (booking.status == BookingStatus.pending && !booking.isPaid) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FlexColors.error,
                      side: const BorderSide(color: FlexColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)),
                    ),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('Payer'),
                  ),
                ),
              ],
            ),
          ],
          if (booking.status == BookingStatus.completed) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReview,
              icon: const Icon(Icons.star_rounded, size: 18),
              label: const Text('Donner mon avis'),
            ),
          ],
        ],
      ),
    );
  }
}
