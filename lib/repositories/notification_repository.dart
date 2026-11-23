import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? refId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.refId,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      refId: json['refId'] ?? json['ref_id'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class NotificationRepository {
  final _api = ApiClient();

  Future<List<AppNotification>> getMyNotifications() async {
    try {
      final response = await _api.dio.get('/notifications');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => AppNotification.fromMap(item as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<bool> markRead(String id) async {
    try {
      final response = await _api.dio.put('/notifications/$id/read');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification read: $e');
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final response = await _api.dio.put('/notifications/read-all');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking all read: $e');
      return false;
    }
  }
}
