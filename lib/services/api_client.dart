import 'package:dio/dio.dart';

import '../config/api_config.dart';

/// Shared HTTP client for requests to the Flex Go backend.
///
/// All API calls should use this client instead of declaring host URLs
/// inside individual services.
class ApiClient {
  ApiClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
}
