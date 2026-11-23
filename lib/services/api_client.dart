import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  static const String _envApiUrl = String.fromEnvironment('API_URL');

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.contains('/auth/login') &&
            !e.requestOptions.path.contains('/auth/refresh')) {
          final success = await _refreshToken();
          if (success) {
            final prefs = await SharedPreferences.getInstance();
            final accessToken = prefs.getString('access_token');
            e.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
            
            try {
              final cloneReq = await dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(cloneReq);
            } catch (err) {
              return handler.next(e);
            }
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('access_token');
            await prefs.remove('refresh_token');
            await prefs.remove('user_id');
          }
        }
        return handler.next(e);
      },
    ));
  }

  static String getBaseUrl() {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/v1';
    }
    return 'http://127.0.0.1:8081/api/v1';
  }

  Future<String?> uploadFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
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

  // Web-safe version using XFile (cross_file)
  Future<String?> uploadXFile(dynamic xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: xfile.name ?? 'upload.jpg'),
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

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl: getBaseUrl(),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ));
      final response = await refreshDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final tokens = data['tokens'] ?? data;
        final newAccess = tokens['accessToken'];
        final newRefresh = tokens['refreshToken'];

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

  static String errorMessage(Object error, {String fallback = 'Une erreur est survenue'}) {
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
          error.type == DioExceptionType.receiveTimeout) {
        return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
      }
    }
    return fallback;
  }
}
