import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Shared HTTP client for every request to the Flex Go API.
///
/// The base URL comes from [ApiConfig] so a single `--dart-define`
/// (`API_BASE_URL`) controls the environment for all builds.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  /// Deduplicates concurrent refresh attempts: only one refresh request
  /// is sent when several calls receive a 401 at the same time.
  static Future<bool>? _refreshFuture;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: getBaseUrl(),
        // Render free-tier cold starts can take ~25s; keep enough headroom.
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final accessToken = prefs.getString('access_token');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final path = e.requestOptions.path;
          final isAuthCall = path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/refresh') ||
              path.contains('/auth/otp') ||
              path.contains('/auth/forgot-password') ||
              path.contains('/auth/reset-password') ||
              path.contains('/auth/password/reset') ||
              path.contains('/auth/logout');

          if (e.response?.statusCode == 401 && !isAuthCall) {
            final success = await _refreshToken();
            if (success) {
              final prefs = await SharedPreferences.getInstance();
              final accessToken = prefs.getString('access_token');
              e.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

              try {
                final cloneReq = await dio.fetch<dynamic>(e.requestOptions);
                return handler.resolve(cloneReq);
              } catch (_) {
                return handler.next(e);
              }
            }

            await clearSession();
          }
          return handler.next(e);
        },
      ),
    );
  }

  static String getBaseUrl() => ApiConfig.baseUrl;

  /// Compatibility accessor for code that expects a shared [Dio].
  static Dio get instance => ApiClient().dio;

  Future<String?> uploadFile(File file) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dio.post('/upload', data: formData);
      return _parseUploadResponse(response);
    } catch (e) {
      debugPrint('Error uploading file: $e');
    }
    return null;
  }

  /// Web-safe upload using an XFile (cross_file).
  Future<String?> uploadXFile(dynamic xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: xfile.name ?? 'upload.jpg',
        ),
      });

      final response = await dio.post('/upload', data: formData);
      return _parseUploadResponse(response);
    } catch (e) {
      debugPrint('Error uploading XFile: $e');
    }
    return null;
  }

  String? _parseUploadResponse(Response response) {
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data['data'];
      if (data != null && data['url'] != null) {
        final relativeUrl = data['url'].toString();
        if (relativeUrl.startsWith('http')) return relativeUrl;
        final hostBase = getBaseUrl().replaceAll('/api/v1', '');
        return '$hostBase$relativeUrl';
      }
    }
    return null;
  }

  Future<bool> _refreshToken() {
    return _refreshFuture ??= _doRefreshToken().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _doRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: getBaseUrl(),
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final tokens = data['tokens'] ?? data;
        final newAccess = tokens['accessToken'];
        final newRefresh = tokens['refreshToken'];

        if (newAccess == null) return false;

        await prefs.setString('access_token', newAccess);
        if (newRefresh != null) {
          await prefs.setString('refresh_token', newRefresh);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
    return false;
  }

  /// Clears the persisted JWT session.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
  }

  static String errorMessage(
    Object error, {
    String fallback = 'Une erreur est survenue',
  }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final apiError = data['error'];
        if (apiError is Map && apiError['details'] != null) {
          return apiError['details'].toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }
      if (error.response?.statusCode == 401) {
        return 'Identifiants invalides';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
      }
    }
    return fallback;
  }
}
