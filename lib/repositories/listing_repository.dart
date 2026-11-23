import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/models.dart';

class ListingRepository {
  final _api = ApiClient();

  /// Fetch all public listings with optional filters
  Future<List<Listing>> getListings({
    String? ville,
    String? search,
    double? prixMin,
    double? prixMax,
    bool? certifiedOnly,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (ville != null && ville.isNotEmpty) queryParams['ville'] = ville;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (prixMin != null) queryParams['min_prix'] = prixMin;
      if (prixMax != null) queryParams['max_prix'] = prixMax;
      if (certifiedOnly == true) queryParams['certified'] = 'true';
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _api.dio.get('/listings', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => Listing.fromMap(_normalizeListingJson(item))).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching listings: $e');
      rethrow;
    }
  }

  /// Statistiques publiques: counts par type + total
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _api.dio.get('/listings/stats');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching listing stats: $e');
      rethrow;
    }
  }

  /// Fetch a single listing by ID
  Future<Listing?> getListingById(String id) async {
    try {
      final response = await _api.dio.get('/listings/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Listing.fromMap(_normalizeListingJson(data));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching listing: $e');
      rethrow;
    }
  }

  /// Create a new listing (host only)
  Future<Listing?> createListing(Map<String, dynamic> listingData) async {
    try {
      final response = await _api.dio.post('/listings', data: listingData);
      if (response.statusCode == 201) {
        return Listing.fromMap(_normalizeListingJson(response.data['data']));
      }
      return null;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      rethrow;
    }
  }

  /// Update an existing listing
  Future<Listing?> updateListing(String id, Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put('/listings/$id', data: data);
      if (response.statusCode == 200) {
        return Listing.fromMap(_normalizeListingJson(response.data['data']));
      }
      return null;
    } catch (e) {
      debugPrint('Error updating listing: $e');
      rethrow;
    }
  }

  /// Delete a listing
  Future<bool> deleteListing(String id) async {
    try {
      final response = await _api.dio.delete('/listings/$id');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting listing: $e');
      rethrow;
    }
  }

  /// Fetch host's own listings
  Future<List<Listing>> getMyListings() async {
    try {
      final response = await _api.dio.get('/listings/mine');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => Listing.fromMap(_normalizeListingJson(item))).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching my listings: $e');
      rethrow;
    }
  }

  /// Normalize Go snake_case JSON keys to Flutter camelCase keys
  Map<String, dynamic> _normalizeListingJson(Map<String, dynamic> json) {
    return {
      'id': json['id'] ?? '',
      'hoteId': json['hoteId'] ?? json['hote_id'] ?? '',
      'titre': json['titre'] ?? '',
      'description': json['description'] ?? '',
      'typeLogement': json['typeLogement'] ?? json['type_logement'] ?? 'chambre',
      'ville': json['ville'] ?? '',
      'quartier': json['quartier'] ?? '',
      'adresse': json['adresse'] ?? '',
      'latitude': json['latitude'] ?? 0.0,
      'longitude': json['longitude'] ?? 0.0,
      'prixParNuit': json['prixParNuit'] ?? json['prix_par_nuit'] ?? 0.0,
      'nombreChambres': json['nombreChambres'] ?? json['nombre_chambres'] ?? 1,
      'photos': json['photos'] ?? [],
      'equipements': json['equipements'] ?? [],
      'certification': json['certification'] ?? 'pending',
      'note': json['note'] ?? 0.0,
      'nombreAvis': json['nombreAvis'] ?? json['nombre_avis'] ?? 0,
      'isDisponible': json['isDisponible'] ?? json['is_disponible'] ?? true,
      'createdAt': json['createdAt'] ?? json['created_at'] ?? '',
    };
  }
}
