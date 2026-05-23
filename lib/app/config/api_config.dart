import 'package:flutter/foundation.dart';

class ApiConfig {
  // Always use production API directly
  static const String baseUrl = 'https://api.ok11.in';

  static const String apiPrefix = '/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

