import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = [
      _NotifData(Icons.check_circle_rounded, 'Réservation confirmée', 'Votre réservation chez Madame Akobi est confirmée.', FlexColors.success, DateTime.now().subtract(const Duration(hours: 2)), false),
      _NotifData(Icons.payment_rounded, 'Paiement reçu', 'Paiement de 15 000 FCFA effectué avec succès.', FlexColors.info, DateTime.now().subtract(const Duration(hours: 5)), false),
      _NotifData(Icons.message_rounded, 'Nouveau message', 'L\'hôte vous a envoyé un message.', FlexColors.primary500, DateTime.now().subtract(const Duration(days: 1)), true),
      _NotifData(Icons.star_rounded, 'Avis reçu', 'Un voyageur a laissé un avis sur votre logement.', FlexColors.warning, DateTime.now().subtract(const Duration(days: 2)), true),
      _NotifData(Icons.verified_rounded, 'Certification', 'Votre logement a été certifié Flex !', FlexColors.success, DateTime.now().subtract(const Duration(days: 3)), true),
    ];

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Notifications', style: FlexTextStyles.h3),
        leading: const BackButton(),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Tout lu', style: TextStyle(fontSize: 13))),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(FlexSpacing.md),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final n = notifications[i];
          return Container(
            padding: const EdgeInsets.all(FlexSpacing.md),
            decoration: BoxDecoration(
              color: n.isUnread ? n.color.withOpacity(0.05) : (isDark ? FlexColors.neutral800 : Colors.white),
              borderRadius: BorderRadius.circular(FlexRadius.lg),
              border: Border.all(color: n.isUnread ? n.color.withOpacity(0.2) : (isDark ? FlexColors.neutral700 : FlexColors.neutral200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: n.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(n.icon, color: n.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(n.title, style: FlexTextStyles.label.copyWith(
                            fontWeight: n.isUnread ? FontWeight.w600 : FontWeight.normal,
                          ))),
                          if (n.isUnread)
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: FlexColors.primary500, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n.body, style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                      const SizedBox(height: 4),
                      Text(_timeAgo(n.time), style: TextStyle(fontSize: 10, color: FlexColors.neutral400)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }
}

class _NotifData {
  final IconData icon; final String title; final String body;
  final Color color; final DateTime time; final bool isUnread;
  _NotifData(this.icon, this.title, this.body, this.color, this.time, this.isUnread);
}
