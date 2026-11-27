/// Central configuration for the Flex Go API.
///
/// Override at build/run time without changing source code:
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// flutter build apk --dart-define=API_BASE_URL=https://api.example.com
class ApiConfig {
  ApiConfig._();

  /// API root, including the version prefix.
  ///
  /// Android emulator users should use http://10.0.2.2:8080/api/v1.
  /// Web/iOS simulator local development can use http://localhost:8080/api/v1.
  /// Production builds should always pass the deployed HTTPS URL.
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static String get baseUrl {
    final value = _configuredBaseUrl.trim();
    return value.endsWith('/')
        ? value.substring(0, value.length - 1)
        : value;
  }

  static bool get isConfiguredForProduction =>
      Uri.tryParse(baseUrl)?.scheme == 'https';
}
