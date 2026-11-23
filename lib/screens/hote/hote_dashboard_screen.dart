import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/listing_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/visit_repository.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import '../../shared/widgets/adaptive_grid.dart';
import '../../shared/widgets/adaptive_overlay.dart';

class HoteDashboardScreen extends StatefulWidget {
  const HoteDashboardScreen({super.key});

  @override
  State<HoteDashboardScreen> createState() => _HoteDashboardScreenState();
}

class _HoteDashboardScreenState extends State<HoteDashboardScreen> {
  int _selectedTab = 0;
  final _listingRepo = ListingRepository();
  final _bookingRepo = BookingRepository();
  final _visitRepo = VisitRepository();
  List<Listing> _mesListings = [];
  List<Booking> _reservations = [];
  int _pendingVisits = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final listings = await _listingRepo.getMyListings();
      final bookings = await _bookingRepo.getMyBookings();
      int pendingVisits = 0;
      try {
        final visits = await _visitRepo.getMyVisits();
        pendingVisits = visits.where((v) => v.status == VisitStatus.pending).length;
      } catch (e) {
        debugPrint('Visits load error: $e');
      }
      if (mounted) {
        setState(() {
          _mesListings = listings;
          _reservations = bookings;
          _pendingVisits = pendingVisits;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Hote dashboard error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: AdaptiveContentContainer(
            child: Column(
              children: [
                _buildHeader(isDark),
                _buildStats(isDark),
                const SizedBox(height: 4),
                _buildRentalManagementBanner(isDark),
                _buildVisitRequestBanner(isDark),
                const SizedBox(height: 8),
                _buildTabBar(isDark),
                Expanded(
                  child: _selectedTab == 0
                      ? _buildListingsTab(isDark)
                      : _buildReservationsTab(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/create-listing');
          if (result != null) _load();
        },
        backgroundColor: FlexColors.primary500,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(FlexSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: FlexColors.primary100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard_rounded, color: FlexColors.primary600),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Hôte', style: FlexTextStyles.h2.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
              )),
              Text('Gérez vos logements', style: FlexTextStyles.caption.copyWith(
                color: FlexColors.neutral500,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    final paidTotal = _reservations
        .where((b) => b.isPaid)
        .fold<double>(0, (sum, b) => sum + b.montantTotal);
    final pendingCount = _reservations.where((b) => b.status == BookingStatus.pending).length;
    final revenueText = paidTotal >= 1000 ? '${(paidTotal / 1000).toStringAsFixed(0)}k' : '${paidTotal.toInt()}';

    final stats = [
      _StatCardData(icon: Icons.home_rounded, value: '${_mesListings.length}', label: 'Logements', color: FlexColors.primary500),
      _StatCardData(icon: Icons.bookmark_rounded, value: '${_reservations.length}', label: 'Réservations', color: FlexColors.info),
      _StatCardData(icon: Icons.hourglass_top_rounded, value: '$pendingCount', label: 'En attente', color: FlexColors.warning),
      _StatCardData(icon: Icons.trending_up_rounded, value: '$revenueText F', label: 'Revenus', color: FlexColors.success),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: Builder(
        builder: (context) {
          // On desktop, show all stats in a 4-column row with more detail
          if (context.isDesktop) {
            return Row(
              children: stats.asMap().entries.map((e) => [
                Expanded(child: _StatCard(icon: e.value.icon, value: e.value.value, label: e.value.label, color: e.value.color)),
                if (e.key < stats.length - 1) const SizedBox(width: 12),
              ]).expand((w) => w).toList(),
            );
          }
          // Mobile/Tablet: original horizontal scroll
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: stats.asMap().entries.map((e) => [
                SizedBox(width: 120, child: _StatCard(icon: e.value.icon, value: e.value.value, label: e.value.label, color: e.value.color)),
                if (e.key < stats.length - 1) const SizedBox(width: 8),
              ]).expand((w) => w).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRentalManagementBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: GestureDetector(
        onTap: () => context.push('/hote-rentals'),
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(FlexSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FlexRadius.lg),
            gradient: LinearGradient(
              colors: isDark
                  ? [FlexColors.neutral800, const Color(0xFF1E3A5F)]
                  : [const Color(0xFFE8F0FE), const Color(0xFFD6E4FF)],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: FlexColors.primary500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_rounded, color: FlexColors.primary600, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gestion locative', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('Locataires, paiements, échéances',
                      style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: FlexColors.primary500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitRequestBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: FlexSpacing.md, right: FlexSpacing.md, top: 4),
      child: GestureDetector(
        onTap: () => context.push('/hote-visits'),
        child: Container(
          padding: const EdgeInsets.all(FlexSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? FlexColors.neutral800 : Colors.white,
            borderRadius: BorderRadius.circular(FlexRadius.lg),
            border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
          ),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: FlexColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.calendar_today_rounded, color: FlexColors.warning, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Demandes de visite', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('$_pendingVisits en attente · Gérez les visites', style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
                ],
              )),
              const Icon(Icons.chevron_right_rounded, size: 18, color: FlexColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(FlexSpacing.md),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
          borderRadius: BorderRadius.circular(FlexRadius.md),
        ),
        child: Row(
          children: [
            _TabBtn(label: 'Mes logements', index: 0, selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
            _TabBtn(label: 'Réservations', index: 1, selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsTab(bool isDark) {
    if (_mesListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: FlexColors.neutral300),
            const SizedBox(height: 16),
            Text('Aucun logement', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
            const SizedBox(height: 8),
            Text('Ajoutez votre premier logement', style: FlexTextStyles.body.copyWith(color: FlexColors.neutral400)),
          ],
        ),
      );
    }

    return AdaptiveGrid<Listing>(
      items: _mesListings,
      mobileCrossAxisCount: 1,
      tabletCrossAxisCount: 1,
      desktopCrossAxisCount: 2,
      largeDesktopCrossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: context.isDesktop ? 3.0 : 4.0,
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md, vertical: 4),
      itemBuilder: (context, listing, i) => _ListingManageCard(
        listing: listing,
        onEdit: () => _showEditListingSheet(listing),
        onToggle: () => _toggleDisponible(listing),
      ),
    );
  }

  Widget _buildReservationsTab(bool isDark) {
    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 64, color: FlexColors.neutral300),
            const SizedBox(height: 16),
            Text('Aucune réservation', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      itemCount: _reservations.length,
      itemBuilder: (context, i) => _buildReservationCard(_reservations[i], isDark),
    );
  }

  Widget _buildReservationCard(Booking booking, bool isDark) {
    final statusColors = switch (booking.status) {
      BookingStatus.confirmed => (FlexColors.success, 'Confirmée'),
      BookingStatus.pending => (FlexColors.warning, 'En attente'),
      BookingStatus.checkedIn => (FlexColors.info, 'En cours'),
      BookingStatus.completed => (FlexColors.neutral400, 'Terminée'),
      BookingStatus.cancelled => (FlexColors.error, 'Annulée'),
    };

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
                  color: statusColors.$1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FlexRadius.full),
                ),
                child: Text(statusColors.$2, style: FlexTextStyles.caption.copyWith(
                  color: statusColors.$1, fontWeight: FontWeight.w600,
                )),
              ),
              const Spacer(),
              Text('${booking.montantTotal.toInt()} FCFA', style: FlexTextStyles.h3.copyWith(
                color: FlexColors.primary500,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Text('Réservation #${booking.id.substring(0, 8)}', style: FlexTextStyles.label.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 4),
          Text('${booking.dateArrivee.day}/${booking.dateArrivee.month} → ${booking.dateDepart.day}/${booking.dateDepart.month} · ${booking.nombreNuits} nuits',
            style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await _bookingRepo.confirmBooking(booking.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Réservation confirmée !' : 'Erreur lors de la confirmation.'),
                            backgroundColor: ok ? FlexColors.success : FlexColors.error,
                          ),
                        );
                        if (ok) _load();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlexColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Accepter', style: TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await _bookingRepo.cancelBooking(booking.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Réservation refusée.' : 'Erreur lors du refus.'),
                            backgroundColor: ok ? FlexColors.neutral600 : FlexColors.error,
                          ),
                        );
                        if (ok) _load();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FlexColors.error,
                      side: const BorderSide(color: FlexColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Refuser', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleDisponible(Listing listing) async {
    try {
      await _listingRepo.updateListing(listing.id, {
        'isDisponible': !listing.isDisponible,
      });
      if (!mounted) return;
      _load();
    } catch (e) {
      debugPrint('Toggle disponibilité error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de modifier la disponibilité')),
      );
    }
  }

  void _showEditListingSheet(Listing listing) {
    AdaptiveOverlay.show(
      context: context,
      child: _ListingFormSheet(isEditing: true, listing: listing, onSaved: _load),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(FlexRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: color,
          )),
          Text(label, style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
        ],
      ),
    );
  }
}

class _StatCardData {
  final IconData icon; final String value; final String label; final Color color;
  const _StatCardData({required this.icon, required this.value, required this.label, required this.color});
}

class _TabBtn extends StatelessWidget {
  final String label; final int index; final bool selected; final VoidCallback onTap;
  const _TabBtn({required this.label, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FlexColors.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(FlexRadius.md),
          ),
          child: Text(label, style: FlexTextStyles.label.copyWith(
            color: selected ? Colors.white : FlexColors.neutral500,
            fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }
}

class _ListingManageCard extends StatelessWidget {
  final Listing listing; final VoidCallback onEdit; final VoidCallback onToggle;
  const _ListingManageCard({required this.listing, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
              borderRadius: BorderRadius.circular(FlexRadius.md),
              image: listing.photos.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(listing.photos.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: listing.photos.isEmpty
                ? Icon(Icons.home_rounded, color: isDark ? FlexColors.neutral500 : FlexColors.neutral300)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.titre, style: FlexTextStyles.label.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 2),
                Text('${listing.prixParNuit.toInt()} FCFA/nuit', style: FlexTextStyles.caption.copyWith(
                  color: FlexColors.primary500,
                )),
              ],
            ),
          ),
          IconButton(
            icon: Icon(listing.isDisponible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: listing.isDisponible ? FlexColors.success : FlexColors.neutral400, size: 20),
            onPressed: onToggle,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: FlexColors.neutral400, size: 20),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _ListingFormSheet extends StatefulWidget {
  final bool isEditing; final Listing? listing; final VoidCallback onSaved;
  const _ListingFormSheet({required this.isEditing, this.listing, required this.onSaved});

  @override
  State<_ListingFormSheet> createState() => _ListingFormSheetState();
}

class _ListingFormSheetState extends State<_ListingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _listingRepo = ListingRepository();
  bool _isSaving = false;
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  late TextEditingController _villeController;
  late TextEditingController _quartierController;
  late TextEditingController _adresseController;
  late TypeLogement _selectedType;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.listing?.titre ?? '');
    _descriptionController = TextEditingController(text: widget.listing?.description ?? '');
    _prixController = TextEditingController(text: widget.listing?.prixParNuit.toInt().toString() ?? '');
    _villeController = TextEditingController(text: widget.listing?.ville ?? '');
    _quartierController = TextEditingController(text: widget.listing?.quartier ?? '');
    _adresseController = TextEditingController(text: widget.listing?.adresse ?? '');
    _selectedType = widget.listing?.typeLogement ?? TypeLogement.chambre;
  }

  String _typeLabel(TypeLogement t) {
    switch (t) {
      case TypeLogement.chambre: return 'Chambre';
      case TypeLogement.studio: return 'Studio';
      case TypeLogement.appartement: return 'Appartement';
      case TypeLogement.villa: return 'Villa';
      case TypeLogement.cohabitation: return 'Cohabitation';
      case TypeLogement.espace: return 'Espace';
      case TypeLogement.club: return 'Club';
      case TypeLogement.autre: return 'Autre';
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _villeController.dispose();
    _quartierController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(FlexSpacing.md),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: FlexColors.neutral300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.isEditing ? 'Modifier le logement' : 'Nouveau logement',
                  style: FlexTextStyles.h2),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre', hintText: 'ex: Chambre calme chez...'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TypeLogement>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type de logement'),
                items: TypeLogement.values.map((t) => DropdownMenuItem(
                  value: t, child: Text(_typeLabel(t), style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prixController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prix/nuit (FCFA)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _villeController,
                      decoration: const InputDecoration(labelText: 'Ville'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quartierController,
                      decoration: const InputDecoration(labelText: 'Quartier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _isSaving = true);
                          try {
                            await _listingRepo.updateListing(widget.listing!.id, {
                              'titre': _titreController.text.trim(),
                              'description': _descriptionController.text.trim(),
                              'typeLogement': _selectedType.name,
                              'prixParNuit': double.tryParse(_prixController.text.trim()) ?? 0,
                              'ville': _villeController.text.trim(),
                              'quartier': _quartierController.text.trim(),
                              'adresse': _adresseController.text.trim(),
                            });
                            if (!mounted) return;
                            Navigator.pop(context);
                            widget.onSaved();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logement modifié')),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: impossible de modifier le logement')),
                            );
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
