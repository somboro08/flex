import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSummary {
  final String recipientId;
  final String listingId;
  final String listingTitre;
  final String listingVille;
  final String listingQuartier;
  final String lastMessage;
  final DateTime lastTime;

  const ChatSummary({
    required this.recipientId,
    required this.listingId,
    required this.listingTitre,
    required this.listingVille,
    required this.listingQuartier,
    required this.lastMessage,
    required this.lastTime,
  });

  factory ChatSummary.fromMap(Map<String, dynamic> map) => ChatSummary(
    recipientId: map['recipientId'] ?? '',
    listingId: map['listingId'] ?? '',
    listingTitre: map['listingTitre'] ?? '',
    listingVille: map['listingVille'] ?? '',
    listingQuartier: map['listingQuartier'] ?? '',
    lastMessage: map['lastMessage'] ?? '',
    lastTime: DateTime.tryParse(map['lastTime'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'recipientId': recipientId,
    'listingId': listingId,
    'listingTitre': listingTitre,
    'listingVille': listingVille,
    'listingQuartier': listingQuartier,
    'lastMessage': lastMessage,
    'lastTime': lastTime.toIso8601String(),
  };
}

class ChatCacheService {
  static const _key = 'chat_conversations';

  Future<void> saveConversation(ChatSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getConversations();
    list.removeWhere((c) => c.recipientId == summary.recipientId);
    list.insert(0, summary);
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toMap()).toList()),
    );
  }

  Future<List<ChatSummary>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final data = jsonDecode(raw) as List;
      return data
          .map((e) => ChatSummary.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.lastTime.compareTo(a.lastTime));
    } catch (_) {
      return [];
    }
  }
}