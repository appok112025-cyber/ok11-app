import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:ok11/app/config/api_config.dart';
import 'package:ok11/app/services/firebase_service.dart';

class _NetworkException implements Exception {
  final String message;
  _NetworkException(this.message);
  @override
  String toString() => message;
}

class ApiService extends GetxService {
  FirebaseService get _firebaseService => Get.find<FirebaseService>();

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$endpoint',
      );
      final headers = await _getHeaders();

      _logRequest('GET', url.toString(), headers, null);

      final response = await http
          .get(url, headers: headers)
          .timeout(
            ApiConfig.receiveTimeout,
            onTimeout: () {
              _logError('GET', url.toString(), 'Request timeout', null);
              throw TimeoutException(
                'Request timeout',
                ApiConfig.receiveTimeout,
              );
            },
          );

      _logResponse('GET', url.toString(), response.statusCode, response.body);
      return response;
    } on TimeoutException catch (e) {
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Request timeout. Please try again.');
    } on SocketException catch (e) {
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException catch (e) {
      _firebaseService.logError(e, StackTrace.current);
      final message = e.message.toLowerCase();
      if (message.contains('connection refused') ||
          message.contains('socket')) {
        throw _NetworkException(
          'Connection failed. Please check your network.',
        );
      }
      throw _NetworkException('Connection failed. Please check your network.');
    } on HttpException catch (e) {
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is SocketException) {
        _firebaseService.logError(e, StackTrace.current);
        throw _NetworkException(
          'No internet connection. Please check your network.',
        );
      }
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$endpoint',
      );
      final headers = await _getHeaders();
      final bodyJson = body != null ? jsonEncode(body) : null;

      _logRequest('POST', url.toString(), headers, bodyJson);

      final response = await http
          .post(url, headers: headers, body: bodyJson)
          .timeout(
            ApiConfig.receiveTimeout,
            onTimeout: () {
              _logError('POST', url.toString(), 'Request timeout', null);
              throw TimeoutException(
                'Request timeout',
                ApiConfig.receiveTimeout,
              );
            },
          );

      _logResponse('POST', url.toString(), response.statusCode, response.body);
      return response;
    } on TimeoutException catch (e) {
      _logError('POST', endpoint, 'Request timeout', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Request timeout. Please try again.');
    } on SocketException catch (e) {
      _logError('POST', endpoint, 'SocketException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException catch (e) {
      _logError('POST', endpoint, 'ClientException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      final message = e.message.toLowerCase();
      if (message.contains('connection refused') ||
          message.contains('socket')) {
        throw _NetworkException(
          'Connection failed. Please check your network.',
        );
      }
      throw _NetworkException('Connection failed. Please check your network.');
    } on HttpException catch (e) {
      _logError('POST', endpoint, 'HttpException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logError('POST', endpoint, 'Unexpected error: $e', e);
      if (e is SocketException) {
        _firebaseService.logError(e, StackTrace.current);
        throw _NetworkException(
          'No internet connection. Please check your network.',
        );
      }
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic>? body) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$endpoint',
      );
      final headers = await _getHeaders();
      final bodyJson = body != null ? jsonEncode(body) : null;

      _logRequest('PUT', url.toString(), headers, bodyJson);

      final response = await http
          .put(url, headers: headers, body: bodyJson)
          .timeout(
            ApiConfig.receiveTimeout,
            onTimeout: () {
              _logError('PUT', url.toString(), 'Request timeout', null);
              throw TimeoutException(
                'Request timeout',
                ApiConfig.receiveTimeout,
              );
            },
          );

      _logResponse('PUT', url.toString(), response.statusCode, response.body);
      return response;
    } on TimeoutException catch (e) {
      _logError('PUT', endpoint, 'Request timeout', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Request timeout. Please try again.');
    } on SocketException catch (e) {
      _logError('PUT', endpoint, 'SocketException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException catch (e) {
      _logError('PUT', endpoint, 'ClientException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      final message = e.message.toLowerCase();
      if (message.contains('connection refused') ||
          message.contains('socket')) {
        throw _NetworkException(
          'Connection failed. Please check your network.',
        );
      }
      throw _NetworkException('Connection failed. Please check your network.');
    } on HttpException catch (e) {
      _logError('PUT', endpoint, 'HttpException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logError('PUT', endpoint, 'Unexpected error: $e', e);
      if (e is SocketException) {
        _firebaseService.logError(e, StackTrace.current);
        throw _NetworkException(
          'No internet connection. Please check your network.',
        );
      }
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}$endpoint',
      );
      final headers = await _getHeaders();

      _logRequest('DELETE', url.toString(), headers, null);

      final response = await http
          .delete(url, headers: headers)
          .timeout(
            ApiConfig.receiveTimeout,
            onTimeout: () {
              _logError('DELETE', url.toString(), 'Request timeout', null);
              throw TimeoutException(
                'Request timeout',
                ApiConfig.receiveTimeout,
              );
            },
          );

      _logResponse(
        'DELETE',
        url.toString(),
        response.statusCode,
        response.body,
      );
      return response;
    } on TimeoutException catch (e) {
      _logError('DELETE', endpoint, 'Request timeout', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Request timeout. Please try again.');
    } on SocketException catch (e) {
      _logError('DELETE', endpoint, 'SocketException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException catch (e) {
      _logError('DELETE', endpoint, 'ClientException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      final message = e.message.toLowerCase();
      if (message.contains('connection refused') ||
          message.contains('socket')) {
        throw _NetworkException(
          'Connection failed. Please check your network.',
        );
      }
      throw _NetworkException('Connection failed. Please check your network.');
    } on HttpException catch (e) {
      _logError('DELETE', endpoint, 'HttpException: ${e.message}', e);
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logError('DELETE', endpoint, 'Unexpected error: $e', e);
      if (e is SocketException) {
        _firebaseService.logError(e, StackTrace.current);
        throw _NetworkException(
          'No internet connection. Please check your network.',
        );
      }
      _firebaseService.logError(e, StackTrace.current);
      throw _NetworkException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  void _logRequest(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  ) {
    final logData = {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _firebaseService.logBreadcrumb('API Request: $method $url', data: logData);
    debugPrint('📤 API Request: $method $url');
    if (body != null) {
      debugPrint('📤 Body: $body');
    }
  }

  void _logResponse(String method, String url, int statusCode, String body) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final logData = {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'body': body.length > 500 ? '${body.substring(0, 500)}...' : body,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (isSuccess) {
      _firebaseService.logBreadcrumb(
        'API Response: $method $url - $statusCode',
        data: logData,
      );
      debugPrint('✅ API Response: $method $url - Status: $statusCode');
    } else {
      _firebaseService.logBreadcrumb(
        'API Error Response: $method $url - $statusCode',
        data: logData,
      );
      debugPrint('❌ API Error Response: $method $url - Status: $statusCode');
      debugPrint(
        '❌ Body: ${body.length > 500 ? "${body.substring(0, 500)}..." : body}',
      );
    }
  }

  void _logError(String method, String url, String error, dynamic exception) {
    final logData = {
      'method': method,
      'url': url,
      'error': error,
      'exception': exception?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    _firebaseService.logBreadcrumb('API Error: $method $url', data: logData);
    debugPrint('🚨 API Error: $method $url');
    debugPrint('🚨 Error: $error');
    if (exception != null) {
      debugPrint('🚨 Exception: $exception');
    }
  }
}
