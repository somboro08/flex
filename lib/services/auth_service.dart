import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/models.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _api = ApiClient();

  bool get isLoggedIn => _accessToken != null;

  String? _accessToken;
  FlexUser? _currentUser;

  FlexUser? get currentUser => _currentUser;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      try {
        await fetchProfile();
      } catch (e) {
        debugPrint('Failed to fetch profile at startup: $e');
        _accessToken = null;
        await ApiClient.clearSession();
      }
    }
  }

  /// Restores a persisted session and returns whether the user is logged in.
  ///
  /// Kept as a compatibility helper for splash/router code.
  Future<bool> restoreSession() async {
    await init();
    return isLoggedIn;
  }

  /// Connexion avec numéro de téléphone + mot de passe (backend Go).
  Future<bool> login(String telephone, String password) async {
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'telephone': telephone,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _storeSession(response.data['data']);
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
    return false;
  }

  /// Inscription (backend Go). L'utilisateur est connecté automatiquement.
  Future<bool> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String password,
    String? email,
    String? role,
  }) async {
    try {
      final response = await _api.dio.post('/auth/register', data: {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
        'role': role ?? 'voyageur',
      });

      if (response.statusCode == 201) {
        await _storeSession(response.data['data']);
        return true;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
    return false;
  }

  Future<void> _storeSession(Map<String, dynamic> data) async {
    final tokens = data['tokens'] ?? data;
    final accessToken = tokens['accessToken'];
    final refreshToken = tokens['refreshToken'];
    final userMap = data['user'];

    if (accessToken == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    _accessToken = accessToken;

    if (userMap != null) {
      _currentUser = FlexUser.fromMap(userMap);
      await prefs.setString('user_id', _currentUser!.id);
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _api.dio.get('/me');
      if (response.statusCode == 200) {
        final userMap = response.data['data'];
        _currentUser = FlexUser.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      rethrow;
    }
  }

  /// L'utilisateur devient propriétaire (hote) — profil adapté au type.
  Future<void> becomeHote() async {
    try {
      final response = await _api.dio.put('/me/role', data: {'role': 'hote'});
      if (response.statusCode == 200) {
        final userMap = response.data['data'];
        _currentUser = FlexUser.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Become hote error: $e');
      rethrow;
    }
  }

  /// Changement de mot de passe (authentifié).
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _api.dio.put('/auth/password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      debugPrint('Change password error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      await _api.dio.post('/auth/logout', data: {
        'refreshToken': refreshToken,
      });
    } catch (e) {
      debugPrint('Logout error on backend: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');
      _accessToken = null;
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Alias for signOut — called by ProfileScreen
  Future<void> logout() => signOut();

  Future<void> updateProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nom != null && nom.isNotEmpty) body['nom'] = nom;
      if (prenom != null && prenom.isNotEmpty) body['prenom'] = prenom;
      if (telephone != null && telephone.isNotEmpty) body['telephone'] = telephone;
      if (email != null) body['email'] = email;
      if (photoUrl != null) body['photoUrl'] = photoUrl;

      final response = await _api.dio.put('/me', data: body);
      if (response.statusCode == 200) {
        final userMap = response.data['data'];
        _currentUser = FlexUser.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> submitIdentity({
    required String idCardUrl,
    String? birthCertificateUrl,
  }) async {
    try {
      await _api.dio.put('/me/identity', data: {
        'idCardUrl': idCardUrl,
        if (birthCertificateUrl != null) 'birthCertificateUrl': birthCertificateUrl,
      });
      await fetchProfile();
    } catch (e) {
      debugPrint('Submit identity error: $e');
      rethrow;
    }
  }
}
