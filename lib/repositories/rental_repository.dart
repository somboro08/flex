import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/rental_models.dart';

/// Locations mensuelles (baux) — synchronisées avec le backend Go.
class RentalRepository {
  final _api = ApiClient();

  /// Locations de l'utilisateur (propriétaire: ses baux; locataire: les siens).
  Future<List<MonthlyRental>> getRentals() async {
    try {
      final response = await _api.dio.get('/rentals');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => MonthlyRental.fromMap(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching rentals: $e');
      rethrow;
    }
  }

  /// Détail d'une location avec paiements et demandes.
  Future<MonthlyRental?> getRentalById(String id) async {
    try {
      final response = await _api.dio.get('/rentals/$id');
      if (response.statusCode == 200) {
        return MonthlyRental.fromMap(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching rental: $e');
      rethrow;
    }
  }

  /// Crée un bail mensuel (propriétaire).
  Future<MonthlyRental?> createRental({
    required String listingId,
    required String voyageurTelephone,
    required String startDate,
    required double monthlyRent,
    double caution = 0,
    int billingDay = 5,
  }) async {
    try {
      final response = await _api.dio.post('/rentals', data: {
        'listingId': listingId,
        'voyageurTelephone': voyageurTelephone,
        'startDate': startDate,
        'monthlyRent': monthlyRent,
        'caution': caution,
        'billingDay': billingDay,
      });
      if (response.statusCode == 201) {
        return MonthlyRental.fromMap(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating rental: $e');
      rethrow;
    }
  }

  /// Enregistre le paiement d'une échéance.
  Future<MonthlyRental?> payRental(
    String rentalId, {
    required String periodLabel,
    double? amount,
    String? transactionRef,
  }) async {
    try {
      final response = await _api.dio.post('/rentals/$rentalId/payments', data: {
        'periodLabel': periodLabel,
        if (amount != null) 'amount': amount,
        if (transactionRef != null && transactionRef.isNotEmpty) 'transactionRef': transactionRef,
      });
      if (response.statusCode == 200) {
        return MonthlyRental.fromMap(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error paying rental: $e');
      rethrow;
    }
  }

  /// Met fin au bail (propriétaire).
  Future<MonthlyRental?> terminateRental(String rentalId) async {
    try {
      final response = await _api.dio.post('/rentals/$rentalId/terminate');
      if (response.statusCode == 200) {
        return MonthlyRental.fromMap(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error terminating rental: $e');
      rethrow;
    }
  }

  /// Demande locataire: avance, remboursement ou renouvellement.
  Future<void> createRequest(
    String rentalId, {
    required String type,
    String message = '',
    double? amount,
  }) async {
    try {
      await _api.dio.post('/rentals/$rentalId/requests', data: {
        'type': type,
        'message': message,
        if (amount != null) 'amount': amount,
      });
    } catch (e) {
      debugPrint('Error creating rental request: $e');
      rethrow;
    }
  }

  /// Réponse du propriétaire à une demande.
  Future<void> respondToRequest(String rentalId, String requestId, {required bool approved}) async {
    try {
      await _api.dio.post('/rentals/$rentalId/requests/$requestId/respond', data: {
        'approved': approved,
      });
    } catch (e) {
      debugPrint('Error responding to rental request: $e');
      rethrow;
    }
  }
}
