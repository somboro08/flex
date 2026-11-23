import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../models/models.dart';

/// Favoris synchronisés avec le backend (users.favorites).
class FavoriteRepository {
  final _api = ApiClient();

  /// Logements favoris de l'utilisateur connecté.
  Future<List<Listing>> getFavorites() async {
    try {
      final response = await _api.dio.get('/me/favorites');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => Listing.fromMap(_normalizeJson(item))).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      rethrow;
    }
  }

  Future<bool> addFavorite(String listingId) async {
    try {
      final response = await _api.dio.post('/me/favorites/$listingId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<bool> removeFavorite(String listingId) async {
    try {
      final response = await _api.dio.delete('/me/favorites/$listingId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
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
