import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock bookings
    final List<Map<String, dynamic>> mockBookings = [
      {
        'id': 'b1',
        'listingTitle': 'Studio meublé Centre-ville',
        'ville': 'Parakou',
        'dateArrivee': DateTime.now().add(const Duration(days: 2)),
        'dateDepart': DateTime.now().add(const Duration(days: 5)),
        'montantTotal': 25500.0,
        'status': BookingStatus.confirmed,
      },
      {
        'id': 'b2',
        'listingTitle': 'Chambre calme chez Madame Akobi',
        'ville': 'Parakou',
        'dateArrivee': DateTime.now().subtract(const Duration(days: 10)),
        'dateDepart': DateTime.now().subtract(const Duration(days: 8)),
        'montantTotal': 10000.0,
        'status': BookingStatus.completed,
      },
      {
        'id': 'b3',
        'listingTitle': 'Chambre familiale avec jardin',
        'ville': 'Parakou',
        'dateArrivee': DateTime.now().add(const Duration(days: 15)),
        'dateDepart': DateTime.now().add(const Duration(days: 20)),
        'montantTotal': 32500.0,
        'status': BookingStatus.pending,
      },
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
        appBar: AppBar(
          title: const Text('Mes Réservations', style: FlexTextStyles.h3),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            indicatorColor: FlexColors.primary500,
            labelColor: FlexColors.primary500,
            unselectedLabelColor: FlexColors.neutral500,
            labelStyle: FlexTextStyles.label.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'En cours'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsList(
              bookings: mockBookings.where((b) => b['status'] != BookingStatus.completed && b['status'] != BookingStatus.cancelled).toList(),
              isDark: isDark,
            ),
            _BookingsList(
              bookings: mockBookings.where((b) => b['status'] == BookingStatus.completed || b['status'] == BookingStatus.cancelled).toList(),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final bool isDark;

  const _BookingsList({required this.bookings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
            ),
            const SizedBox(height: FlexSpacing.md),
            Text(
              'Aucune réservation',
              style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(FlexSpacing.md),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: FlexSpacing.md),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking, isDark: isDark);
      },
    );
    }
    }

class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  final bool isDark;

  const _BookingCard({required this.booking, required this.isDark});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.booking['status']);
    final statusLabel = _getStatusLabel(widget.booking['status']);
    final dateFormat = DateFormat('dd MMM yyyy', 'fr');

    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: widget.isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(
          color: widget.isDark ? FlexColors.neutral700 : FlexColors.neutral200,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FlexRadius.full),
                ),
                child: Text(
                  statusLabel,
                  style: FlexTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '#${widget.booking['id'].toUpperCase()}',
                style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400),
              ),
            ],
          ),
          const SizedBox(height: FlexSpacing.md),
          Text(
            widget.booking['listingTitle'],
            style: FlexTextStyles.h3.copyWith(
              color: widget.isDark ? FlexColors.neutral0 : FlexColors.neutral800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: FlexColors.neutral400),
              const SizedBox(width: 4),
              Text(
                widget.booking['ville'],
                style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
              ),
            ],
          ),
          const SizedBox(height: FlexSpacing.md),
          Row(
            children: [
              _DateInfo(
                label: 'Arrivée',
                date: dateFormat.format(widget.booking['dateArrivee']),
                isDark: widget.isDark,
              ),
              const SizedBox(width: FlexSpacing.xl),
              _DateInfo(
                label: 'Départ',
                date: dateFormat.format(widget.booking['dateDepart']),
                isDark: widget.isDark,
              ),
            ],
          ),
          if (widget.booking['status'] == BookingStatus.confirmed ||
              widget.booking['status'] == BookingStatus.checkedIn) ...[
            const SizedBox(height: FlexSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final dateArrivee = widget.booking['dateArrivee'] as DateTime;
                final dateDepart = widget.booking['dateDepart'] as DateTime;
                final now = DateTime.now();

                final totalDuration = dateDepart.difference(dateArrivee).inDays;
                final elapsedDuration = now.difference(dateArrivee).inDays;

                double progress = 0.0;
                if (totalDuration > 0) {
                  progress = elapsedDuration / totalDuration;
                  if (progress < 0) progress = 0.0; // Booking not started
                  if (progress > 1) progress = 1.0; // Booking completed
                } else if (now.isAfter(dateDepart)) {
                  progress = 1.0; // Already completed if duration is 0
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progression du séjour',
                      style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                    ),
                    const SizedBox(height: FlexSpacing.xs),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: widget.isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                      valueColor: const AlwaysStoppedAnimation<Color>(FlexColors.primary500),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(FlexRadius.full),
                    ),
                  ],
                );
              },
            ),
          ],
          const Divider(height: FlexSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant Total',
                    style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400),
                  ),
                  Text(
                    '${widget.booking['montantTotal'].toInt()} FCFA',
                    style: FlexTextStyles.h3.copyWith(
                      color: FlexColors.primary500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (widget.booking['status'] == BookingStatus.confirmed)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlexColors.info,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Gérer'),
                ),
              if (widget.booking['status'] == BookingStatus.pending)
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Annuler'),
                ),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Plus d\'options',
              style: FlexTextStyles.label.copyWith(color: FlexColors.primary500),
            ),
            children: [
              if (widget.booking['status'] == BookingStatus.confirmed ||
                  widget.booking['status'] == BookingStatus.checkedIn)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Action to renew widget.booking
                    },
                    child: const Text('Renouveler la réservation'),
                  ),
                ),
              if (widget.booking['status'] == BookingStatus.completed ||
                  widget.booking['status'] == BookingStatus.cancelled)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Action to rebook
                    },
                    child: const Text('Re-réserver'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return FlexColors.warning;
      case BookingStatus.confirmed: return FlexColors.success;
      case BookingStatus.checkedIn: return FlexColors.info;
      case BookingStatus.completed: return FlexColors.neutral500;
      case BookingStatus.cancelled: return FlexColors.error;
    }
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return 'En attente';
      case BookingStatus.confirmed: return 'Confirmé';
      case BookingStatus.checkedIn: return 'En séjour';
      case BookingStatus.completed: return 'Terminé';
      case BookingStatus.cancelled: return 'Annulé';
    }
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String date;
  final bool isDark;

  const _DateInfo({required this.label, required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral400),
        ),
        Text(
          date,
          style: FlexTextStyles.label.copyWith(
            color: isDark ? FlexColors.neutral200 : FlexColors.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
