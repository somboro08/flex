import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class AuditRepository {
  final _api = ApiClient();

  Future<bool> createAudit({
    required String listingId,
    required bool serrure,
    required bool literie,
    required bool sanitaires,
    required bool eclairage,
    required bool identite,
    required bool photosFideles,
    required bool adresse,
    String commentaires = '',
  }) async {
    try {
      final response = await _api.dio.post('/audits', data: {
        'listingId': listingId,
        'serrure': serrure,
        'literie': literie,
        'sanitaires': sanitaires,
        'eclairage': eclairage,
        'identite': identite,
        'photosFideles': photosFideles,
        'adresse': adresse,
        'commentaires': commentaires,
      });

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating audit: $e');
      rethrow;
    }
  }
}
