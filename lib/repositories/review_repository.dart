import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class ReviewRepository {
  final _api = ApiClient();

  Future<bool> createReview({
    required String bookingId,
    required String listingId,
    required int note,
    String commentaire = '',
  }) async {
    try {
      final response = await _api.dio.post('/reviews', data: {
        'bookingId': bookingId,
        'listingId': listingId,
        'note': note,
        if (commentaire.isNotEmpty) 'commentaire': commentaire,
      });
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getListingReviews(String listingId) async {
    try {
      final response = await _api.dio.get('/listings/$listingId/reviews');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      rethrow;
    }
  }
}
