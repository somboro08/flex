import 'package:flutter/material.dart';
import '../../theme/flex_theme.dart';
import '../../repositories/notification_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notifRepo = NotificationRepository();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _notifRepo.getMyNotifications();
      if (mounted) setState(() { _notifications = list; _isLoading = false; });
    } catch (e) {
      debugPrint('Notif error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    await _notifRepo.markAllRead();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Notifications', style: FlexTextStyles.h3),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Tout lu', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 64, color: FlexColors.neutral300),
                      const SizedBox(height: 16),
                      Text('Aucune notification', style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(FlexSpacing.md),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      return _NotifCard(
                        notif: n,
                        isDark: isDark,
                        onTap: () async {
                          if (!n.isRead) {
                            await _notifRepo.markRead(n.id);
                            _load();
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final bool isDark;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.isDark, required this.onTap});

  static const _typeIcons = <String, IconData>{
    'booking_confirmed': Icons.check_circle_rounded,
    'booking_cancelled': Icons.cancel_rounded,
    'visit_confirmed': Icons.calendar_today_rounded,
    'visit_cancelled': Icons.event_busy_rounded,
    'new_message': Icons.message_rounded,
    'listing_certified': Icons.verified_rounded,
    'review_received': Icons.star_rounded,
    'system': Icons.info_rounded,
  };

  static const _typeColors = <String, Color>{
    'booking_confirmed': FlexColors.success,
    'booking_cancelled': FlexColors.error,
    'visit_confirmed': FlexColors.info,
    'visit_cancelled': FlexColors.error,
    'new_message': FlexColors.primary500,
    'listing_certified': FlexColors.success,
    'review_received': FlexColors.warning,
    'system': FlexColors.neutral400,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcons[notif.type] ?? Icons.notifications_rounded;
    final color = _typeColors[notif.type] ?? FlexColors.neutral400;
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FlexSpacing.md),
        decoration: BoxDecoration(
          color: isUnread ? color.withValues(alpha: 0.05) : (isDark ? FlexColors.neutral800 : Colors.white),
          borderRadius: BorderRadius.circular(FlexRadius.lg),
          border: Border.all(
            color: isUnread ? color.withValues(alpha: 0.2) : (isDark ? FlexColors.neutral700 : FlexColors.neutral200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(notif.title, style: FlexTextStyles.label.copyWith(
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                      ))),
                      if (isUnread)
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: FlexColors.primary500, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.body, style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500)),
                  const SizedBox(height: 4),
                  Text(_timeAgo(notif.createdAt), style: const TextStyle(fontSize: 10, color: FlexColors.neutral400)),
                ],
              ),
            ),
          ],
        ),
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
