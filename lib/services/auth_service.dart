import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Authentication backed exclusively by the Flex REST API.
class AuthService {
  static const _accessTokenKey = 'flex_access_token';
  static const _refreshTokenKey = 'flex_refresh_token';

  static const _accessTokenHeader = 'Authorization';

  Dio get _api => ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String telephone,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: {'telephone': telephone, 'password': password},
      );
      final data = _responseData(response.data);
      await _saveSession(data);
      return Map<String, dynamic>.from(data['user'] as Map);
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error, 'Connexion impossible.'));
    }
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String telephone,
    String? email,
    required String password,
    String role = 'voyageur',
  }) async {
    try {
      final payload = <String, dynamic>{
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'password': password,
        'role': role,
      };
      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim();
      }

      final response = await _api.post('/auth/register', data: payload);
      final data = _responseData(response.data);
      await _saveSession(data);
      return Map<String, dynamic>.from(data['user'] as Map);
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error, 'Inscription impossible.'));
    }
  }

  /// Restores the local JWT session and validates it against GET /me.
  /// If the access token expired, one refresh attempt is made.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);

    if (accessToken == null || accessToken.isEmpty) return false;
    _setAccessToken(accessToken);

    try {
      await _api.get('/me');
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode != 401 ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        await _clearSession();
        return false;
      }
    }

    try {
      final response = await _api.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      await _saveSession(_responseData(response.data));
      await _api.get('/me');
      return true;
    } catch (_) {
      await _clearSession();
      return false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _api.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await _clearSession();
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final tokens = data['tokens'];
    if (tokens is! Map) {
      throw const AuthException('Réponse API invalide : jetons absents.');
    }

    final accessToken = tokens['accessToken']?.toString();
    final refreshToken = tokens['refreshToken']?.toString();
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const AuthException('Réponse API invalide : jetons incomplets.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _setAccessToken(accessToken);
  }

  void _setAccessToken(String token) {
    _api.options.headers[_accessTokenHeader] = 'Bearer $token';
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _api.options.headers.remove(_accessTokenHeader);
  }

  Map<String, dynamic> _responseData(dynamic response) {
    if (response is! Map) {
      throw const AuthException('Réponse API invalide.');
    }
    final data = response['data'];
    if (data is! Map) {
      throw const AuthException('Données API manquantes.');
    }
    return Map<String, dynamic>.from(data);
  }

  String _messageFrom(DioException error, String fallback) {
    final body = error.response?.data;
    if (body is Map) {
      final apiError = body['error'];
      if (apiError is Map && apiError['details'] != null) {
        return apiError['details'].toString();
      }
      if (body['message'] != null) return body['message'].toString();
    }
    if (error.response == null) {
      return 'Serveur inaccessible. Vérifiez votre connexion et API_BASE_URL.';
    }
    return fallback;
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
