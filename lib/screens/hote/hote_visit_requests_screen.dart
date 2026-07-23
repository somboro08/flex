import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';

class HoteVisitRequestsScreen extends StatefulWidget {
  const HoteVisitRequestsScreen({super.key});

  @override
  State<HoteVisitRequestsScreen> createState() => _HoteVisitRequestsScreenState();
}

class _HoteVisitRequestsScreenState extends State<HoteVisitRequestsScreen> {
  final List<VisitReservation> _visits = [
    VisitReservation(id: 'v1', listingId: 'l1', listingTitle: 'Villa Ouidah', voyageurId: 'u1', voyageurNom: 'Amadou Diallo', voyageurTelephone: '+229 97 11 22 33', hoteId: 'h1', dateVisite: DateTime(2026, 7, 25), timeSlot: 'Matin (9h-12h)', message: 'Bonjour, je suis très intéressé par la villa.', status: VisitStatus.pending, createdAt: DateTime.now()),
    VisitReservation(id: 'v2', listingId: 'l2', listingTitle: 'Studio Cotonou', voyageurId: 'u2', voyageurNom: 'Fatou Sow', voyageurTelephone: '+229 97 44 55 66', hoteId: 'h1', dateVisite: DateTime(2026, 7, 26), timeSlot: 'Après-midi (14h-17h)', message: '', status: VisitStatus.pending, createdAt: DateTime.now()),
    VisitReservation(id: 'v3', listingId: 'l1', listingTitle: 'Villa Ouidah', voyageurId: 'u3', voyageurNom: 'Kofi Mensah', voyageurTelephone: '+229 97 77 88 99', hoteId: 'h1', dateVisite: DateTime(2026, 7, 24), timeSlot: 'Matin (9h-12h)', message: 'Disponible samedi matin ?', status: VisitStatus.confirmed, createdAt: DateTime.now()),
    VisitReservation(id: 'v4', listingId: 'l3', listingTitle: 'Chambre Parakou', voyageurId: 'u4', voyageurNom: 'Marie Koffi', voyageurTelephone: '+229 97 33 44 55', hoteId: 'h1', dateVisite: DateTime(2026, 7, 23), timeSlot: 'Soirée (17h-19h)', message: '', status: VisitStatus.completed, createdAt: DateTime.now()),
  ];

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

  void _updateStatus(String id, VisitStatus newStatus) {
    setState(() {
      final idx = _visits.indexWhere((v) => v.id == id);
      if (idx != -1) {
        final old = _visits[idx];
        _visits[idx] = VisitReservation(
          id: old.id, listingId: old.listingId, listingTitle: old.listingTitle,
          voyageurId: old.voyageurId, voyageurNom: old.voyageurNom, voyageurTelephone: old.voyageurTelephone,
          hoteId: old.hoteId, dateVisite: old.dateVisite, timeSlot: old.timeSlot,
          message: old.message, status: newStatus, createdAt: old.createdAt,
        );
      }
    });
  }
}
