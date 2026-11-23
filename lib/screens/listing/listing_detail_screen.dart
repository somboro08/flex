import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../repositories/favorite_repository.dart';
import '../../widgets/flex_badge.dart';
import '../../widgets/flex_map_widget.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/content_container.dart';
import 'visit_request_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  DateTime? _dateArrivee;
  DateTime? _dateDepart;
  bool _isFavorite = false;
  final _favRepo = FavoriteRepository();

  @override
  void initState() {
    super.initState();
    _loadFav();
    StorageService.addRecentView(widget.listing.id);
  }

  void _loadFav() async {
    try {
      bool fav;
      if (AuthService().isLoggedIn) {
        final favs = await _favRepo.getFavorites();
        fav = favs.any((l) => l.id == widget.listing.id);
      } else {
        fav = await StorageService.isFavorite(widget.listing.id);
      }
      if (mounted) setState(() => _isFavorite = fav);
    } catch (e) {
      debugPrint('Load favorite error: $e');
    }
  }

  void _toggleFav() async {
    try {
      if (AuthService().isLoggedIn) {
        if (_isFavorite) {
          await _favRepo.removeFavorite(widget.listing.id);
        } else {
          await _favRepo.addFavorite(widget.listing.id);
        }
      } else {
        await StorageService.toggleFavorite(widget.listing.id);
      }
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      debugPrint('Favorite toggle error: $e');
    }
  }

  void _goToBooking() {
    context.push(
      '/book/${widget.listing.id}',
      extra: widget.listing,
    );
  }

  void _share() {
    Share.share(
      '🏠 ${widget.listing.titre}\n📍 ${widget.listing.quartier}, ${widget.listing.ville}\n💰 ${widget.listing.prixParNuit.toInt()} FCFA/nuit\n⭐ ${widget.listing.note.toStringAsFixed(1)} (${widget.listing.nombreAvis} avis)\n\nDécouvre Flex - Hébergement économique certifié',
    );
  }

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: FlexColors.primary500,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _dateArrivee = range.start;
        _dateDepart = range.end;
      });
    }
  }

  int get _nombreNuits {
    if (_dateArrivee == null || _dateDepart == null) return 0;
    return _dateDepart!.difference(_dateArrivee!).inDays;
  }

  double get _montantTotal => widget.listing.prixParNuit * _nombreNuits;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listing = widget.listing;

    // On desktop, use a two-column layout
    if (context.isDesktop) {
      return _buildDesktopLayout(context, isDark, listing);
    }
    return _buildMobileLayout(context, isDark, listing);
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark, Listing listing) {
    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        backgroundColor: isDark ? FlexColors.neutral900 : Colors.white,
        elevation: 0.5,
        title: Text(listing.titre, style: FlexTextStyles.h3.copyWith(
          color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
        )),
        actions: [
          Tooltip(
            message: 'Partager',
            child: IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: _share,
            ),
          ),
          Tooltip(
            message: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFav,
            ),
          ),
        ],
      ),
      body: AdaptiveContentContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT COLUMN — gallery + description
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FlexSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image gallery
                    ClipRRect(
                      borderRadius: BorderRadius.circular(FlexRadius.lg),
                      child: SizedBox(
                        height: 320,
                        child: listing.photos.isNotEmpty
                            ? PageView.builder(
                                itemCount: listing.photos.length,
                                itemBuilder: (_, i) => Image.network(
                                  listing.photos[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                                    child: const Center(child: Icon(Icons.broken_image, size: 40, color: FlexColors.neutral400)),
                                  ),
                                ),
                              )
                            : Container(
                                color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                                child: const Center(child: Icon(Icons.home_rounded, size: 80, color: FlexColors.neutral300)),
                              ),
                      ),
                    ),
                    const SizedBox(height: FlexSpacing.lg),
                    // Info
                    _buildListingInfo(isDark, listing),
                    const Divider(height: 32),
                    _buildEquipements(isDark, listing),
                    const Divider(height: 32),
                    _buildMapSection(isDark, listing),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            // RIGHT COLUMN — booking panel
            SizedBox(
              width: 360,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FlexSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceHeader(isDark, listing),
                    const SizedBox(height: FlexSpacing.md),
                    _buildDatePicker(isDark),
                    if (_nombreNuits > 0) ...[
                      const SizedBox(height: 12),
                      _buildPriceSummary(isDark, listing),
                    ],
                    const SizedBox(height: FlexSpacing.md),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VisitRequestScreen(listing: listing)),
                          ),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                          child: const Text('Demander une visite'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nombreNuits > 0 ? _goToBooking : _pickDates,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: Text(_nombreNuits > 0 ? 'Réserver · ${_montantTotal.toInt()} FCFA' : 'Choisir les dates'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, Listing listing) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: _toggleFav,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.red : Colors.white, size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: _share,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                child: listing.photos.isNotEmpty
                    ? PageView.builder(
                        itemCount: listing.photos.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            listing.photos[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image, color: FlexColors.neutral400, size: 40)),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Icon(Icons.home_rounded, size: 80,
                              color: isDark ? FlexColors.neutral600 : FlexColors.neutral300),
                            Text(listing.ville, style: FlexTextStyles.body.copyWith(
                              color: isDark ? FlexColors.neutral500 : FlexColors.neutral400,
                            )),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(FlexSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.titre,
                          style: FlexTextStyles.h2.copyWith(
                            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CertificationBadge(status: listing.certification),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: FlexColors.neutral400),
                      Text(
                        '${listing.quartier}, ${listing.ville}',
                        style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                      ),
                    ],
                  ),
                  const SizedBox(height: FlexSpacing.md),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: FlexColors.warning),
                      Text(
                        ' ${listing.note.toStringAsFixed(1)}',
                        style: FlexTextStyles.label.copyWith(
                          color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' · ${listing.nombreAvis} avis',
                        style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                      ),
                      const Spacer(),
                      Text(
                        '${listing.prixParNuit.toInt()} FCFA',
                        style: FlexTextStyles.h3.copyWith(color: FlexColors.primary500),
                      ),
                      Text(
                        ' /nuit',
                        style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description
                  Text(
                    'À propos',
                    style: FlexTextStyles.h3.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
                  ),
                  const Divider(height: 32),

                  // Equipements
                  Text(
                    'Équipements',
                    style: FlexTextStyles.h3.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: listing.equipements.map((e) => FlexBadge(
                      label: e,
                      color: FlexColors.primary500,
                      icon: Icons.check_circle_rounded,
                    )).toList(),
                  ),
                  const Divider(height: 32),

                  // Map section — Localisation interactive
                  Text(
                    'Localisation',
                    style: FlexTextStyles.h3.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlexMapWidget(
                    latitude: listing.latitude,
                    longitude: listing.longitude,
                    title: listing.titre,
                    isCertified: listing.certification == 'certified',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: FlexColors.neutral400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.adresse}, ${listing.quartier}, ${listing.ville}',
                          style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Date picker
                  Text(
                    'Choisir les dates',
                    style: FlexTextStyles.h3.copyWith(
                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDates,
                    child: Container(
                      padding: const EdgeInsets.all(FlexSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? FlexColors.neutral800 : FlexColors.neutral100,
                        borderRadius: BorderRadius.circular(FlexRadius.md),
                        border: Border.all(
                          color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Arrivée', style: FlexTextStyles.caption.copyWith(
                                  color: FlexColors.neutral400,
                                )),
                                Text(
                                  _dateArrivee != null
                                      ? '${_dateArrivee!.day}/${_dateArrivee!.month}/${_dateArrivee!.year}'
                                      : 'Choisir',
                                  style: FlexTextStyles.body.copyWith(
                                    color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 0.5,
                            height: 36,
                            color: isDark ? FlexColors.neutral600 : FlexColors.neutral300,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Départ', style: FlexTextStyles.caption.copyWith(
                                    color: FlexColors.neutral400,
                                  )),
                                  Text(
                                    _dateDepart != null
                                        ? '${_dateDepart!.day}/${_dateDepart!.month}/${_dateDepart!.year}'
                                        : 'Choisir',
                                    style: FlexTextStyles.body.copyWith(
                                      color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, color: FlexColors.primary500),
                        ],
                      ),
                    ),
                  ),

                  if (_nombreNuits > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(FlexSpacing.md),
                      decoration: BoxDecoration(
                        color: FlexColors.primary50,
                        borderRadius: BorderRadius.circular(FlexRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_nombreNuits nuit${_nombreNuits > 1 ? 's' : ''} × ${listing.prixParNuit.toInt()} FCFA',
                            style: FlexTextStyles.body.copyWith(color: FlexColors.primary700),
                          ),
                          Text(
                            '${_montantTotal.toInt()} FCFA',
                            style: FlexTextStyles.h3.copyWith(color: FlexColors.primary600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Book button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(FlexSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
          border: Border(
            top: BorderSide(
              color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${listing.prixParNuit.toInt()} FCFA',
                  style: FlexTextStyles.h3.copyWith(color: FlexColors.primary500),
                ),
                Text(
                  'par nuit',
                  style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                ),
              ],
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VisitRequestScreen(listing: listing))),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
              child: const Text('Visite', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _nombreNuits > 0
                    ? _goToBooking
                    : _pickDates,
                child: Text(_nombreNuits > 0 ? 'Réserver · ${_montantTotal.toInt()} FCFA' : 'Choisir les dates'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingInfo(bool isDark, Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                listing.titre,
                style: FlexTextStyles.h2.copyWith(
                  color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CertificationBadge(status: listing.certification),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 16, color: FlexColors.neutral400),
            Text(
              '${listing.quartier}, ${listing.ville}',
              style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
            ),
          ],
        ),
        const SizedBox(height: FlexSpacing.md),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18, color: FlexColors.warning),
            Text(
              ' ${listing.note.toStringAsFixed(1)}',
              style: FlexTextStyles.label.copyWith(
                color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' · ${listing.nombreAvis} avis',
              style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'À propos',
          style: FlexTextStyles.h3.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          listing.description,
          style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
        ),
      ],
    );
  }

  Widget _buildEquipements(bool isDark, Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Équipements',
          style: FlexTextStyles.h3.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: listing.equipements.map((e) => FlexBadge(
            label: e,
            color: FlexColors.primary500,
            icon: Icons.check_circle_rounded,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMapSection(bool isDark, Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localisation',
          style: FlexTextStyles.h3.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        FlexMapWidget(
          latitude: listing.latitude,
          longitude: listing.longitude,
          title: listing.titre,
          isCertified: listing.certification == 'certified',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: FlexColors.neutral400),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${listing.adresse}, ${listing.quartier}, ${listing.ville}',
                style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceHeader(bool isDark, Listing listing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${listing.prixParNuit.toInt()} FCFA',
          style: FlexTextStyles.h2.copyWith(color: FlexColors.primary500),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4),
          child: Text(
            '/ nuit',
            style: FlexTextStyles.body.copyWith(color: FlexColors.neutral500),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir les dates',
          style: FlexTextStyles.h3.copyWith(
            color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDates,
          child: Container(
            padding: const EdgeInsets.all(FlexSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? FlexColors.neutral800 : FlexColors.neutral100,
              borderRadius: BorderRadius.circular(FlexRadius.md),
              border: Border.all(
                color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arrivée', style: FlexTextStyles.caption.copyWith(
                        color: FlexColors.neutral400,
                      )),
                      Text(
                        _dateArrivee != null
                            ? '${_dateArrivee!.day}/${_dateArrivee!.month}/${_dateArrivee!.year}'
                            : 'Choisir',
                        style: FlexTextStyles.body.copyWith(
                          color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 36,
                  color: isDark ? FlexColors.neutral600 : FlexColors.neutral300,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Départ', style: FlexTextStyles.caption.copyWith(
                          color: FlexColors.neutral400,
                        )),
                        Text(
                          _dateDepart != null
                              ? '${_dateDepart!.day}/${_dateDepart!.month}/${_dateDepart!.year}'
                              : 'Choisir',
                          style: FlexTextStyles.body.copyWith(
                            color: isDark ? FlexColors.neutral0 : FlexColors.neutral700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_rounded, color: FlexColors.primary500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(bool isDark, Listing listing) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: FlexColors.primary50,
        borderRadius: BorderRadius.circular(FlexRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_nombreNuits nuit${_nombreNuits > 1 ? 's' : ''} × ${listing.prixParNuit.toInt()} FCFA',
            style: FlexTextStyles.body.copyWith(color: FlexColors.primary700),
          ),
          Text(
            '${_montantTotal.toInt()} FCFA',
            style: FlexTextStyles.h3.copyWith(color: FlexColors.primary600),
          ),
        ],
      ),
    );
  }
}
