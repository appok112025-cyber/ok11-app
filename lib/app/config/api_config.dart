import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Priority 1: explicit override via --dart-define=API_BASE_URL=...
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Priority 2: local development
    if (kDebugMode) {
      final localUrl = defaultTargetPlatform == TargetPlatform.android 
        ? 'http://10.0.2.2:5925' 
        : 'http://localhost:5925';
      print('🚀 Using local API: $localUrl');
      return localUrl;
    }

    // Priority 3: production
    return 'https://api.ok11.in';
  }

  static const String apiPrefix = '/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
