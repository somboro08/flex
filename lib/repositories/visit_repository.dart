import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class VisitRepository {
  final _api = ApiClient();

  /// Create a visit request
  Future<bool> createVisit({
    required String listingId,
    required String dateVisite,
    required String timeSlot,
    String message = '',
  }) async {
    try {
      final response = await _api.dio.post('/visits', data: {
        'listingId': listingId,
        'dateVisite': dateVisite,
        'timeSlot': timeSlot,
        'message': message,
      });
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating visit: $e');
      rethrow;
    }
  }

  /// Fetch all visits for the current user
  Future<List<VisitReservation>> getMyVisits() async {
    try {
      final response = await _api.dio.get('/visits');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => VisitReservation.fromMap(_normalizeVisitJson(item))).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching visits: $e');
      rethrow;
    }
  }

  /// Confirm a visit (host only)
  Future<bool> confirmVisit(String id) async {
    try {
      final response = await _api.dio.post('/visits/$id/confirm');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error confirming visit: $e');
      rethrow;
    }
  }

  /// Cancel a visit
  Future<bool> cancelVisit(String id) async {
    try {
      final response = await _api.dio.post('/visits/$id/cancel');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error cancelling visit: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeVisitJson(Map<String, dynamic> json) {
    // Extract voyageur info from nested object if available
    final voyageur = json['voyageur'] as Map<String, dynamic>?;
    final listing = json['listing'] as Map<String, dynamic>?;

    return {
      'id': json['id'] ?? '',
      'listingId': json['listingId'] ?? json['listing_id'] ?? '',
      'listingTitle': listing?['titre'] ?? json['listingTitle'] ?? '',
      'voyageurId': json['voyageurId'] ?? json['voyageur_id'] ?? '',
      'voyageurNom': voyageur != null 
          ? '${voyageur['prenom'] ?? ''} ${voyageur['nom'] ?? ''}'.trim()
          : (json['voyageurNom'] ?? ''),
      'voyageurTelephone': voyageur?['telephone'] ?? json['voyageurTelephone'] ?? '',
      'hoteId': json['hoteId'] ?? json['hote_id'] ?? '',
      'dateVisite': json['dateVisite'] ?? json['date_visite'] ?? '',
      'timeSlot': json['timeSlot'] ?? json['time_slot'] ?? '',
      'message': json['message'] ?? '',
      'status': json['status'] ?? 'pending',
      'createdAt': json['createdAt'] ?? json['created_at'] ?? '',
    };
  }
}
