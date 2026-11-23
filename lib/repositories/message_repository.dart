import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class MessageRepository {
  final _api = ApiClient();

  Future<bool> sendMessage({
    required String recipientId,
    required String content,
    String? listingId,
  }) async {
    try {
      final response = await _api.dio.post('/messages', data: {
        'recipientId': recipientId,
        'content': content,
        if (listingId != null) 'listingId': listingId,
      });
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getConversation(String otherUserId) async {
    try {
      final response = await _api.dio.get('/messages/$otherUserId');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
      rethrow;
    }
  }
}
