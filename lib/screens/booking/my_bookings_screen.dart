import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedFilter = 0;
  final _filters = ['Tout', 'À venir', 'En cours', 'Terminé', 'Annulé'];

  final List<Booking> _bookings = [
    Booking(id: 'b1', voyageurId: 'v1', listingId: 'l1', hoteId: 'h1',
      dateArrivee: DateTime.now().add(const Duration(days: 5)),
      dateDepart: DateTime.now().add(const Duration(days: 8)),
      nombreNuits: 3, montantTotal: 15000, status: BookingStatus.confirmed,
      paymentMethod: PaymentMethod.mtnMomo, isPaid: true, createdAt: DateTime.now()),
    Booking(id: 'b2', voyageurId: 'v1', listingId: 'l2', hoteId: 'h2',
      dateArrivee: DateTime.now().add(const Duration(days: 15)),
      dateDepart: DateTime.now().add(const Duration(days: 18)),
      nombreNuits: 3, montantTotal: 25500, status: BookingStatus.pending,
      paymentMethod: PaymentMethod.wave, isPaid: false, createdAt: DateTime.now()),
    Booking(id: 'b3', voyageurId: 'v1', listingId: 'l3', hoteId: 'h3',
      dateArrivee: DateTime.now().subtract(const Duration(days: 10)),
      dateDepart: DateTime.now().subtract(const Duration(days: 7)),
      nombreNuits: 3, montantTotal: 15000, status: BookingStatus.completed,
      isPaid: true, createdAt: DateTime.now()),
  ];

  List<Booking> get _filtered {
    if (_selectedFilter == 0) return _bookings;
    return _bookings.where((b) {
      switch (_selectedFilter) {
        case 1: return b.status == BookingStatus.confirmed;
        case 2: return b.status == BookingStatus.checkedIn;
        case 3: return b.status == BookingStatus.completed;
        case 4: return b.status == BookingStatus.cancelled;
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(FlexSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes réservations', style: FlexTextStyles.h2.copyWith(
                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                  )),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final sel = _selectedFilter == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? FlexColors.primary500 : Colors.transparent,
                              borderRadius: BorderRadius.circular(FlexRadius.full),
                              border: Border.all(color: sel ? FlexColors.primary500 : FlexColors.neutral300),
                            ),
                            child: Text(_filters[i], style: FlexTextStyles.caption.copyWith(
                              color: sel ? Colors.white : FlexColors.neutral500,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                            )),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 64, color: FlexColors.neutral300),
                        const SizedBox(height: 16),
                        Text('Aucune réservation', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _BookingCard(booking: _filtered[i], isDark: isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking; final bool isDark;
  const _BookingCard({required this.booking, required this.isDark});

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FlexRadius.full),
                ),
                child: Text(_statusLabel(), style: FlexTextStyles.caption.copyWith(
                  color: _statusColor(), fontWeight: FontWeight.w600,
                )),
              ),
              const Spacer(),
              Text('${booking.montantTotal.toInt()} FCFA', style: FlexTextStyles.h3.copyWith(color: FlexColors.primary500)),
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
                    Text('Réservation #${booking.id.toUpperCase()}', style: FlexTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${booking.dateArrivee.day}/${booking.dateArrivee.month}/${booking.dateArrivee.year} → ${booking.dateDepart.day}/${booking.dateDepart.month}/${booking.dateDepart.year}',
                      style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                    Text('${booking.nombreNuits} nuits', style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                  ],
                ),
              ),
            ],
          ),
          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
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
                    onPressed: () => Navigator.pushNamed(context, '/payment'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('Payer'),
                  ),
                ),
              ],
            ),
          ],
          if (booking.status == BookingStatus.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Donner mon avis'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
