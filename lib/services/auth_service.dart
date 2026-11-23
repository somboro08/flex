import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'api_client.dart';

/// Authentication backed exclusively by the Flex REST API.
class AuthService {
  AuthService() {
    _installInterceptors();
  }

  static const _accessTokenKey = 'flex_access_token';
  static const _refreshTokenKey = 'flex_refresh_token';

  static bool _interceptorsInstalled = false;
  static Future<String?>? _refreshFuture;

  Dio get _api => ApiClient.instance;

  void _installInterceptors() {
    if (_interceptorsInstalled) return;
    _interceptorsInstalled = true;

    _api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString(_accessTokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // Continue; public API calls should still be possible.
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final isAuthRoute = request.path.contains('/auth/');
          if (error.response?.statusCode != 401 ||
              isAuthRoute ||
              request.extra['authRetry'] == true) {
            handler.next(error);
            return;
          }

          try {
            final accessToken = await _refreshAccessToken();
            if (accessToken == null) {
              handler.next(error);
              return;
            }

            request.headers['Authorization'] = 'Bearer $accessToken';
            request.extra['authRetry'] = true;
            final response = await _api.fetch<dynamic>(request);
            handler.resolve(response);
          } catch (_) {
            await _clearSession();
            handler.next(error);
          }
        },
      ),
    );
  }

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

  /// Restores and validates the JWT session against GET /me.
  /// The interceptor refreshes an expired access token automatically.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) return false;

    _setAccessToken(accessToken);
    try {
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

  Future<String?> _refreshAccessToken() {
    final current = _refreshFuture;
    if (current != null) return current;

    final pending = _performRefresh();
    _refreshFuture = pending;
    return pending.whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _performRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final refreshClient = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final response = await refreshClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = _responseData(response.data);
    final tokens = data['tokens'];
    if (tokens is! Map) {
      throw const AuthException('Réponse API invalide : jetons absents.');
    }

    final accessToken = tokens['accessToken']?.toString();
    final newRefreshToken = tokens['refreshToken']?.toString();
    if (accessToken == null ||
        accessToken.isEmpty ||
        newRefreshToken == null ||
        newRefreshToken.isEmpty) {
      throw const AuthException('Réponse API invalide : jetons incomplets.');
    }

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, newRefreshToken);
    _setAccessToken(accessToken);
    return accessToken;
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
    _api.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _api.options.headers.remove('Authorization');
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
