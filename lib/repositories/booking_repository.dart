import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class BookingRepository {
  final _api = ApiClient();

  /// Fetch all bookings for the current user (as voyageur or hote)
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _api.dio.get('/bookings');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => Booking.fromMap(_normalizeBookingJson(item))).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      rethrow;
    }
  }

  /// Fetch a single booking by ID
  Future<Booking?> getBookingById(String id) async {
    try {
      final response = await _api.dio.get('/bookings/$id');
      if (response.statusCode == 200) {
        return Booking.fromMap(_normalizeBookingJson(response.data['data']));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      rethrow;
    }
  }

  /// Create a new booking
  Future<Booking?> createBooking({
    required String listingId,
    required String dateArrivee,
    required String dateDepart,
  }) async {
    try {
      final response = await _api.dio.post('/bookings', data: {
        'listingId': listingId,
        'dateArrivee': dateArrivee,
        'dateDepart': dateDepart,
      });
      if (response.statusCode == 201) {
        return Booking.fromMap(_normalizeBookingJson(response.data['data']));
      }
      return null;
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String id) async {
    try {
      final response = await _api.dio.post('/bookings/$id/cancel');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      rethrow;
    }
  }

  /// Confirm a booking (host only)
  Future<bool> confirmBooking(String id) async {
    try {
      final response = await _api.dio.post('/bookings/$id/confirm');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error confirming booking: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeBookingJson(Map<String, dynamic> json) {
    return {
      'id': json['id'] ?? '',
      'voyageurId': json['voyageurId'] ?? json['voyageur_id'] ?? '',
      'listingId': json['listingId'] ?? json['listing_id'] ?? '',
      'hoteId': json['hoteId'] ?? json['hote_id'] ?? '',
      'dateArrivee': json['dateArrivee'] ?? json['date_arrivee'] ?? '',
      'dateDepart': json['dateDepart'] ?? json['date_depart'] ?? '',
      'nombreNuits': json['nombreNuits'] ?? json['nombre_nuits'] ?? 1,
      'montantTotal': json['montantTotal'] ?? json['montant_total'] ?? 0.0,
      'status': json['status'] ?? 'pending',
      'paymentMethod': json['paymentMethod'] ?? json['payment_method'],
      'isPaid': json['isPaid'] ?? json['is_paid'] ?? false,
      'createdAt': json['createdAt'] ?? json['created_at'] ?? '',
    };
  }
}
