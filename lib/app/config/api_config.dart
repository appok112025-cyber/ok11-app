class ApiConfig {
  static String get baseUrl {
    final envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    return 'https://api.ok11.in';
  }

  static const String apiPrefix = '/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
