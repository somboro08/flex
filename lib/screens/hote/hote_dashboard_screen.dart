import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class HoteDashboardScreen extends StatefulWidget {
  const HoteDashboardScreen({super.key});

  @override
  State<HoteDashboardScreen> createState() => _HoteDashboardScreenState();
}

class _HoteDashboardScreenState extends State<HoteDashboardScreen> {
  int _selectedTab = 0;

  final List<Listing> _mesListings = [
    Listing(
      id: '1', hoteId: 'h1', titre: 'Chambre calme chez Madame Akobi',
      description: 'Chambre propre avec ventilateur.', ville: 'Parakou',
      quartier: 'Zongo', adresse: 'Rue des Artisans', latitude: 9.337,
      longitude: 2.628, prixParNuit: 5000, photos: [],
      equipements: ['Ventilateur', 'WiFi'], certification: CertificationStatus.certified,
      note: 4.8, nombreAvis: 23, createdAt: DateTime.now(),
    ),
    Listing(
      id: '2', hoteId: 'h1', titre: 'Studio meublé Centre-ville',
      description: 'Studio indépendant avec cuisine.', ville: 'Parakou',
      quartier: 'Kpébié', adresse: 'Avenue de la Liberté', latitude: 9.341,
      longitude: 2.624, prixParNuit: 8500, photos: [],
      equipements: ['Climatisation', 'WiFi', 'Cuisine'], certification: CertificationStatus.certified,
      note: 4.6, nombreAvis: 11, createdAt: DateTime.now(),
    ),
  ];

  final List<Booking> _reservations = [
    Booking(
      id: 'b1', voyageurId: 'v1', listingId: '1', hoteId: 'h1',
      dateArrivee: DateTime.now().add(const Duration(days: 3)),
      dateDepart: DateTime.now().add(const Duration(days: 6)),
      nombreNuits: 3, montantTotal: 15000, status: BookingStatus.confirmed,
      paymentMethod: PaymentMethod.mtnMomo, isPaid: true, createdAt: DateTime.now(),
    ),
    Booking(
      id: 'b2', voyageurId: 'v2', listingId: '2', hoteId: 'h1',
      dateArrivee: DateTime.now().add(const Duration(days: 10)),
      dateDepart: DateTime.now().add(const Duration(days: 12)),
      nombreNuits: 2, montantTotal: 17000, status: BookingStatus.pending,
      paymentMethod: PaymentMethod.wave, isPaid: false, createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddListingSheet(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.home_rounded, value: '${_mesListings.length}',
            label: 'Logements', color: FlexColors.primary500,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.bookmark_rounded, value: '${_reservations.length}',
            label: 'Réservations', color: FlexColors.info,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.star_rounded, value: '4.7',
            label: 'Note', color: FlexColors.warning,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.trending_up_rounded, value: '${_reservations.where((b) => b.isPaid).length * 15000} F',
            label: 'Revenus', color: FlexColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildRentalManagementBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/hote-rentals'),
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
        onTap: () => Navigator.pushNamed(context, '/hote-visits'),
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
                  Text('2 en attente · Gérez les visites', style: TextStyle(fontSize: 11, color: FlexColors.neutral500)),
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
            _TabBtn(label: 'Mes logements', index: 0, selected: _selectedTab == 0),
            _TabBtn(label: 'Réservations', index: 1, selected: _selectedTab == 1),
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FlexSpacing.md),
      itemCount: _mesListings.length,
      itemBuilder: (context, i) {
        final listing = _mesListings[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ListingManageCard(
            listing: listing,
            onEdit: () => _showEditListingSheet(listing),
            onToggle: () {
              setState(() => listing.isDisponible = !listing.isDisponible);
            },
          ),
        );
      },
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlexColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Accepter', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
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

  void _showAddListingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      ),
      builder: (_) => const _ListingFormSheet(isEditing: false),
    );
  }

  void _showEditListingSheet(Listing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FlexRadius.xl)),
      ),
      builder: (_) => _ListingFormSheet(isEditing: true, listing: listing),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label; final int index; final bool selected;
  const _TabBtn({required this.label, required this.index, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final state = context.findAncestorStateOfType<_HoteDashboardScreenState>();
          state?.setState(() => state._selectedTab = index);
        },
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
            ),
            child: Icon(Icons.home_rounded, color: isDark ? FlexColors.neutral500 : FlexColors.neutral300),
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
  final bool isEditing; final Listing? listing;
  const _ListingFormSheet({required this.isEditing, this.listing});

  @override
  State<_ListingFormSheet> createState() => _ListingFormSheetState();
}

class _ListingFormSheetState extends State<_ListingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  late TextEditingController _villeController;
  late TextEditingController _quartierController;
  late TextEditingController _adresseController;
  TypeLogement _selectedType = TypeLogement.chambre;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.listing?.titre ?? '');
    _descriptionController = TextEditingController(text: widget.listing?.description ?? '');
    _prixController = TextEditingController(text: widget.listing?.prixParNuit.toInt().toString() ?? '');
    _villeController = TextEditingController(text: widget.listing?.ville ?? '');
    _quartierController = TextEditingController(text: widget.listing?.quartier ?? '');
    _adresseController = TextEditingController(text: widget.listing?.adresse ?? '');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(widget.isEditing ? 'Logement modifié' : 'Logement créé'),
                      ));
                    }
                  },
                  child: Text(widget.isEditing ? 'Enregistrer' : 'Créer le logement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
