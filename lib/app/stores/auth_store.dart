import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:ok11/app/services/api_service.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/services/app_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phone;
  final String role;
  final bool blocked;

  User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phone,
    required this.role,
    required this.blocked,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('User data is null');
    }
    return User(
      id: (json['_id'] as String?) ?? '',
      firebaseUid: (json['firebaseUid'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      phone: json['phone'] as String?,
      role: (json['role'] as String?) ?? 'user',
      blocked: json['blocked'] as bool? ?? false,
    );
  }
}

class AuthStore extends GetxController {
  ApiService get _apiService => Get.find<ApiService>();
  FirebaseService get _firebaseService => Get.find<FirebaseService>();

  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final user = Rxn<User>();
  final token = RxnString();
  final errorMessage = ''.obs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _fcmTokenKey = 'fcm_token';

  /// Completer to track when stored auth has been loaded
  final Completer<void> _authLoadedCompleter = Completer<void>();

  /// Future that completes when stored auth has been loaded
  Future<void> get authLoaded => _authLoadedCompleter.future;

  @override
  void onInit() {
    super.onInit();
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      if (token != null && userJson != null) {
        this.token.value = token;
        _apiService.setAuthToken(token);
        try {
          final decoded = jsonDecode(userJson);
          final userMap = decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : null;
          if (userMap != null) {
            final userData = User.fromJson(userMap);
            user.value = userData;
            isAuthenticated.value = true;
            _checkAndUpdateFcmToken();
          }
        } catch (e) {
          _firebaseService.logError(e, StackTrace.current);
          await clearAuth();
        }
      }
    } catch (e) {
      _firebaseService.logError(e, StackTrace.current);
      await clearAuth();
    } finally {
      if (!_authLoadedCompleter.isCompleted) {
        _authLoadedCompleter.complete();
      }
    }
  }

  Future<void> setAuth(String token, User userData) async {
    try {
      this.token.value = token;
      _apiService.setAuthToken(token);
      user.value = userData;
      isAuthenticated.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(
        _userKey,
        jsonEncode({
          '_id': userData.id,
          'firebaseUid': userData.firebaseUid,
          'email': userData.email,
          'displayName': userData.displayName,
          'photoURL': userData.photoURL,
          'phone': userData.phone,
          'role': userData.role,
          'blocked': userData.blocked,
        }),
      );

      _firebaseService.setUserContext(
        userId: userData.firebaseUid,
        email: userData.email,
        userName: userData.displayName,
      );

      _checkAndUpdateFcmToken();
    } catch (e) {
      _firebaseService.logError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> setAuthToken(String token) async {
    try {
      this.token.value = token;
      _apiService.setAuthToken(token);
      isAuthenticated.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      _firebaseService.logError(e, StackTrace.current);
    }
  }

  Future<void> clearAuth() async {
    try {
      this.token.value = null;
      _apiService.setAuthToken(null);
      user.value = null;
      isAuthenticated.value = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_fcmTokenKey);
    } catch (e) {
      _firebaseService.logError(e, StackTrace.current);
    }
  }

  Future<User> getCurrentUser({String? token}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      final response = await _apiService.get('/auth/me');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          throw Exception('Invalid response format');
        }
        final data = json['data'] as Map<String, dynamic>?;
        final userJson = data?['user'] as Map<String, dynamic>?;
        if (userJson == null) {
          throw Exception('User data not found in response');
        }
        final userData = User.fromJson(userJson);
        user.value = userData;
        return userData;
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Session expired. Please sign in again.';
        throw Exception('Unauthorized: Session expired');
      } else {
        try {
          final decoded = jsonDecode(response.body);
          final error = decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : null;
          final message = error?['message'] as String? ?? 'Failed to get user';
          errorMessage.value = message;
          throw Exception(message);
        } catch (e) {
          errorMessage.value = 'Failed to get user';
          throw Exception('Failed to get user');
        }
      }
    } catch (e) {
      if (errorMessage.value.isEmpty) {
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('connection') ||
            errorMsg.contains('timeout') ||
            errorMsg.contains('network')) {
          errorMessage.value = 'Network error. Please check your connection.';
        } else if (errorMsg.contains('401') ||
            errorMsg.contains('unauthorized')) {
          errorMessage.value = 'Session expired. Please sign in again.';
        } else {
          errorMessage.value = 'Failed to get user data.';
        }
      }
      _firebaseService.logError(e, StackTrace.current);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    // Skip if not authenticated
    if (!isAuthenticated.value || user.value == null) {
      return;
    }

    try {
      final appServices = Get.find<AppServices>();
      await _apiService.put('/auth/fcm-token', {
        'fcmToken': fcmToken,
        'lastLoginAt': DateTime.now().toIso8601String(),
        'appVersion': appServices.appVersion.value,
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, fcmToken);
    } catch (e) {
      _firebaseService.logError(e, StackTrace.current);
    }
  }

  Future<void> _checkAndUpdateFcmToken() async {
    if (!isAuthenticated.value) return;

    try {
      final currentToken = await _firebaseService.getFcmToken();
      if (currentToken == null) return;

      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString(_fcmTokenKey);

      if (storedToken != currentToken) {
        await updateFcmToken(currentToken);
      }
    } catch (e) {
      _firebaseService.logError(e, StackTrace.current);
    }
  }

  Future<void> updateProfile({String? displayName, String? phone}) async {
    // Skip if not authenticated
    if (!isAuthenticated.value || user.value == null) {
      throw Exception('User not authenticated');
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final body = <String, dynamic>{};

      if (displayName != null) {
        body['displayName'] = displayName;
      }

      if (phone != null) {
        body['phone'] = phone;
      }

      final response = await _apiService.put('/auth/profile', body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          throw Exception('Invalid response format');
        }
        final data = json['data'] as Map<String, dynamic>?;
        final userJson = data?['user'] as Map<String, dynamic>?;
        if (userJson == null) {
          throw Exception('User data not found in response');
        }
        final userData = User.fromJson(userJson);
        user.value = userData;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _userKey,
          jsonEncode({
            '_id': userData.id,
            'firebaseUid': userData.firebaseUid,
            'email': userData.email,
            'displayName': userData.displayName,
            'photoURL': userData.photoURL,
            'phone': userData.phone,
            'role': userData.role,
            'blocked': userData.blocked,
          }),
        );
      } else {
        try {
          final decoded = jsonDecode(response.body);
          final error = decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : null;
          throw Exception(
            error?['message'] as String? ?? 'Failed to update profile',
          );
        } catch (e) {
          throw Exception('Failed to update profile');
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _firebaseService.logError(e, StackTrace.current);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
