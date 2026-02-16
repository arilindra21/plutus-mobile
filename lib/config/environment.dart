/// Environment configuration for API endpoints
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://expense-api-staging-740443181568.asia-southeast2.run.app',
  );

  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  static const bool enableLogging = true;
}
