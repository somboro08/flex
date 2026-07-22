import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Réservation confirmée',
        'message': 'Votre demande pour "Studio meublé Centre-ville" a été acceptée par l\'hôte.',
        'time': 'Il y a 2h',
        'isRead': false,
        'icon': Icons.check_circle_rounded,
        'color': FlexColors.success,
      },
      {
        'title': 'Nouvelle offre spéciale',
        'message': 'Profitez de -10% sur votre prochain séjour à Cotonou avec le code FLEX10.',
        'time': 'Il y a 5h',
        'isRead': false,
        'icon': Icons.local_offer_rounded,
        'color': FlexColors.warning,
      },
      {
        'title': 'Audit terminé',
        'message': 'Le logement "Chambre calme chez Madame Akobi" est désormais certifié.',
        'time': 'Hier',
        'isRead': true,
        'icon': Icons.verified_rounded,
        'color': FlexColors.certified,
      },
      {
        'title': 'Rappel de séjour',
        'message': 'N\'oubliez pas votre séjour demain à 14:00.',
        'time': 'Hier',
        'isRead': true,
        'icon': Icons.calendar_today_rounded,
        'color': FlexColors.info,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Notifications', style: FlexTextStyles.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(FlexSpacing.md),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: FlexSpacing.sm),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationItem(notif: notif, isDark: isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: isDark ? FlexColors.neutral700 : FlexColors.neutral200,
          ),
          const SizedBox(height: FlexSpacing.lg),
          Text(
            'Aucune notification',
            style: FlexTextStyles.h2.copyWith(
              color: isDark ? FlexColors.neutral300 : FlexColors.neutral700,
            ),
          ),
          const SizedBox(height: FlexSpacing.sm),
          Text(
            'Vous serez averti ici des activités importantes.',
            style: FlexTextStyles.body.copyWith(
              color: FlexColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notif;
  final bool isDark;

  const _NotificationItem({required this.notif, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FlexSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? FlexColors.neutral800 : FlexColors.neutral0,
        borderRadius: BorderRadius.circular(FlexRadius.lg),
        border: Border.all(
          color: notif['isRead']
              ? (isDark ? FlexColors.neutral700 : FlexColors.neutral200)
              : FlexColors.primary500.withOpacity(0.3),
          width: notif['isRead'] ? 0.5 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (notif['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notif['icon'],
              size: 20,
              color: notif['color'],
            ),
          ),
          const SizedBox(width: FlexSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif['title'],
                      style: FlexTextStyles.label.copyWith(
                        fontWeight: notif['isRead'] ? FontWeight.w500 : FontWeight.w700,
                        color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                      ),
                    ),
                    Text(
                      notif['time'],
                      style: FlexTextStyles.caption.copyWith(
                        color: FlexColors.neutral400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif['message'],
                  style: FlexTextStyles.body.copyWith(
                    color: isDark ? FlexColors.neutral400 : FlexColors.neutral500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!notif['isRead'])
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8, top: 6),
              decoration: const BoxDecoration(
                color: FlexColors.primary500,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
