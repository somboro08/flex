import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../repositories/visit_repository.dart';

class HoteVisitRequestsScreen extends StatefulWidget {
  const HoteVisitRequestsScreen({super.key});

  @override
  State<HoteVisitRequestsScreen> createState() => _HoteVisitRequestsScreenState();
}

class _HoteVisitRequestsScreenState extends State<HoteVisitRequestsScreen> {
  final _visitRepo = VisitRepository();
  List<VisitReservation> _visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final list = await _visitRepo.getMyVisits();
      if (mounted) {
        setState(() {
          _visits = list;
        });
      }
    } catch (e) {
      debugPrint('Error loading visits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FlexColors.neutral900 : FlexColors.neutral50;
    final cardColor = isDark ? FlexColors.neutral800 : Colors.white;
    final pending = _visits.where((v) => v.status == VisitStatus.pending).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Demandes de visite', style: FlexTextStyles.h3),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FlexSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(FlexSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isDark ? [FlexColors.neutral800, FlexColors.neutral900] : [Colors.white, FlexColors.neutral50]),
                borderRadius: BorderRadius.circular(FlexRadius.lg),
                border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
              ),
              child: Row(
                children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: FlexColors.primary500.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.calendar_today_rounded, color: FlexColors.primary500, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_visits.length} demande(s) de visite', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? FlexColors.neutral0 : FlexColors.neutral800)),
                      Text('$pending en attente', style: TextStyle(fontSize: 12, color: FlexColors.primary500)),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._visits.map((v) => _buildVisitCard(v, isDark, cardColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(VisitReservation v, bool isDark, Color cardColor) {
    final statusColor = v.status == VisitStatus.pending ? FlexColors.warning : v.status == VisitStatus.confirmed ? const Color(0xFF10B981) : v.status == VisitStatus.completed ? FlexColors.neutral400 : FlexColors.error;
    final statusLabel = v.status == VisitStatus.pending ? 'En attente' : v.status == VisitStatus.confirmed ? 'Confirmée' : v.status == VisitStatus.completed ? 'Terminée' : 'Annulée';
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(color: isDark ? FlexColors.neutral700 : FlexColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: FlexColors.primary100,
                child: Text(v.voyageurNom[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, color: FlexColors.primary500, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.voyageurNom, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(v.voyageurTelephone, style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.home_rounded, size: 14, color: FlexColors.neutral400),
            const SizedBox(width: 4),
            Text(v.listingTitle, style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 12, color: FlexColors.neutral400),
            const SizedBox(width: 4),
            Text('${v.dateVisite.day} ${months[v.dateVisite.month - 1]} ${v.dateVisite.year}', style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
            const SizedBox(width: 8),
            Icon(Icons.access_time_rounded, size: 12, color: FlexColors.neutral400),
            const SizedBox(width: 4),
            Text(v.timeSlot, style: TextStyle(fontSize: 12, color: FlexColors.neutral500)),
          ]),
          if (v.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? FlexColors.neutral700 : FlexColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('"${v.message}"', style: TextStyle(fontSize: 12, color: FlexColors.neutral500, fontStyle: FontStyle.italic)),
            ),
          ],
          if (v.status == VisitStatus.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _updateStatus(v.id, VisitStatus.confirmed)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Confirmer', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _updateStatus(v.id, VisitStatus.cancelled)),
                    style: OutlinedButton.styleFrom(foregroundColor: FlexColors.error, side: const BorderSide(color: FlexColors.error), padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Refuser', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _updateStatus(String id, VisitStatus newStatus) async {
    try {
      if (newStatus == VisitStatus.confirmed) {
        await _visitRepo.confirmVisit(id);
      } else if (newStatus == VisitStatus.cancelled) {
        await _visitRepo.cancelVisit(id);
      }
      _loadVisits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
}
