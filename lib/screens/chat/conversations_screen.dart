import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/flex_theme.dart';
import '../../models/models.dart';
import '../../services/chat_cache_service.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _cache = ChatCacheService();
  List<ChatSummary> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _cache.getConversations();
    if (!mounted) return;
    setState(() {
      _conversations = list;
      _isLoading = false;
    });
  }

  void _openChat(ChatSummary c) {
    final listing = Listing(
      id: c.listingId,
      hoteId: c.recipientId,
      titre: c.listingTitre,
      description: '',
      ville: c.listingVille,
      quartier: c.listingQuartier,
      adresse: '',
      latitude: 0,
      longitude: 0,
      prixParNuit: 0,
      photos: const [],
      equipements: const [],
      createdAt: DateTime.now(),
    );
    context
        .push(
          '/chat/${c.recipientId}',
          extra: listing,
        )
        .then((_) => _load());
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    if (t.year == now.year && t.month == now.month && t.day == now.day) {
      return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FlexColors.neutral900 : FlexColors.neutral50,
      appBar: AppBar(
        title: const Text('Messagerie', style: FlexTextStyles.h3),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FlexColors.primary500))
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 64, color: FlexColors.neutral300),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune discussion',
                        style: FlexTextStyles.h3.copyWith(color: FlexColors.neutral400),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contactez un hôte depuis la fiche d\'un logement\npour démarrer une conversation.',
                        textAlign: TextAlign.center,
                        style: FlexTextStyles.caption.copyWith(color: FlexColors.neutral500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(FlexSpacing.md),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = _conversations[i];
                      return Material(
                        color: isDark ? FlexColors.neutral800 : Colors.white,
                        borderRadius: BorderRadius.circular(FlexRadius.lg),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(FlexRadius.lg),
                          onTap: () => _openChat(c),
                          child: Padding(
                            padding: const EdgeInsets.all(FlexSpacing.md),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: FlexColors.primary100,
                                  child: Text(
                                    c.listingTitre.isNotEmpty ? c.listingTitre[0] : '?',
                                    style: const TextStyle(
                                      color: FlexColors.primary500,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hôte · ${c.listingTitre}',
                                        style: FlexTextStyles.label.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? FlexColors.neutral0 : FlexColors.neutral800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        c.lastMessage,
                                        style: FlexTextStyles.caption.copyWith(
                                          color: FlexColors.neutral500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTime(c.lastTime),
                                  style: FlexTextStyles.caption.copyWith(
                                    color: FlexColors.neutral400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}