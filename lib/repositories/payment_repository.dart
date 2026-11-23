import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class PaymentReceipt {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final String method;
  final String status;
  final String? providerRef;
  final String? phoneNumber;
  final DateTime? paidAt;

  const PaymentReceipt({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.providerRef,
    this.phoneNumber,
    this.paidAt,
  });

  factory PaymentReceipt.fromMap(Map<String, dynamic> map) {
    return PaymentReceipt(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? map['booking_id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'XOF',
      method: map['method'] ?? '',
      status: map['status'] ?? '',
      providerRef: map['providerRef'] ?? map['provider_ref'],
      phoneNumber: map['phoneNumber'] ?? map['phone_number'],
      paidAt: map['paidAt'] != null ? DateTime.tryParse(map['paidAt'].toString()) : null,
    );
  }
}

/// Paiement des réservations (mobile money simulé côté backend).
class PaymentRepository {
  final _api = ApiClient();

  /// Paye une réservation. Retourne le reçu + la réservation mise à jour.
  Future<({PaymentReceipt payment, Booking booking})> pay({
    required String bookingId,
    required String method,
    String? phoneNumber,
  }) async {
    try {
      final response = await _api.dio.post('/payments', data: {
        'bookingId': bookingId,
        'method': method,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      });
      if (response.statusCode == 201) {
        final data = response.data['data'];
        return (
          payment: PaymentReceipt.fromMap(data['payment']),
          booking: Booking.fromMap(_normalizeBookingJson(data['booking'])),
        );
      }
      throw Exception('Paiement impossible');
    } catch (e) {
      debugPrint('Error paying booking: $e');
      rethrow;
    }
  }

  Future<List<PaymentReceipt>> getMyPayments() async {
    try {
      final response = await _api.dio.get('/payments');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => PaymentReceipt.fromMap(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching payments: $e');
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
      'paymentStatus': json['paymentStatus'] ?? json['payment_status'] ?? 'pending',
      'isPaid': json['isPaid'] ?? json['is_paid'] ?? false,
      'transactionId': json['transactionId'] ?? json['transaction_id'],
      'createdAt': json['createdAt'] ?? json['created_at'] ?? '',
    };
  }
}
