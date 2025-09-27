class AppConfig {
  static const String appName = 'Pet Grooming';

  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String prodBaseUrl = 'https://pet-grooming-api-280062257907.us-central1.run.app/api/v1';
  static const String fallbackUrl = 'http://10.0.2.2:8080/api/v1'; // Android emulator localhost
  static const String testUrl = 'https://httpbin.org'; // Test connectivity

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  static String get apiBaseUrl => prodBaseUrl; // Use freshly deployed Cloud Run backend
}