import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class SplashController extends GetxController {
  final progressValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 SplashController.onInit()');
    _startProgress();
  }

  void _startProgress() async {
    debugPrint('⏳ SplashController._startProgress()');
    const steps = 10;
    const stepDuration = Duration(milliseconds: 30);

    Future.microtask(() => _checkAuthAndNavigate());

    for (int i = 0; i <= steps; i++) {
      await Future.delayed(stepDuration);
      final x = i / steps;
      final eased = x * x * (3 - 2 * x);
      progressValue.value = eased;
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await _checkAuthAndNavigateInternal().timeout(
        const Duration(seconds: 35),
        onTimeout: () {
          _handleNetworkError();
        },
      );
    } catch (e) {
      _handleNetworkError();
    }
  }

  Future<void> _checkAuthAndNavigateInternal() async {
    debugPrint('🔐 SplashController._checkAuthAndNavigateInternal()');
    final authStore = Get.find<AuthStore>();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // If no Firebase user, user has logged out - go to login
    if (firebaseUser == null) {
      debugPrint('⚠️ SplashController: No Firebase user, navigating to LOGIN');
      await authStore.clearAuth();
      Future.microtask(() => Get.offAllNamed(Routes.LOGIN));
      return;
    }

    // Firebase user exists - user is logged in via Google
    // Get a fresh token (Firebase handles refresh automatically)
    String? idToken;
    try {
      idToken = await firebaseUser.getIdToken(true);
    } catch (e) {
      debugPrint(
        '⚠️ SplashController: Failed to get token, retrying without force refresh',
      );
      try {
        idToken = await firebaseUser.getIdToken();
      } catch (e) {
        debugPrint('⚠️ SplashController: Still failed to get token');
      }
    }

    if (idToken == null) {
      // Can't get token but Firebase user exists - use cached data and go to dashboard
      debugPrint(
        '⚠️ SplashController: No token but Firebase user exists, using cached data',
      );
      await authStore.authLoaded;
      if (authStore.user.value?.blocked == true) {
        Future.microtask(() => Get.offAllNamed(Routes.BLOCKED));
        return;
      }
      Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));
      return;
    }

    // We have a valid token - try to fetch fresh user data from API
    try {
      final userData = await authStore.getCurrentUser(token: idToken);

      if (userData.blocked) {
        debugPrint('🚫 SplashController: User blocked, navigating to BLOCKED');
        await authStore.setAuth(idToken, userData);
        Future.microtask(() => Get.offAllNamed(Routes.BLOCKED));
        return;
      }

      await authStore.setAuth(idToken, userData);
      debugPrint('✅ SplashController: Auth set, navigating to DASHBOARD');
      Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));

      // Update FCM token in background
      Get.find<FirebaseService>()
          .getFcmToken()
          .then((fcmToken) {
            if (fcmToken != null) {
              authStore.updateFcmToken(fcmToken);
            }
          })
          .catchError((_) {});
    } catch (e) {
      debugPrint('⚠️ SplashController: API error: $e');
      // API failed but Firebase user exists - use cached data and go to dashboard
      await authStore.authLoaded;

      // Update token in auth store even if API failed
      authStore.setAuthToken(idToken);

      if (authStore.user.value?.blocked == true) {
        Future.microtask(() => Get.offAllNamed(Routes.BLOCKED));
        return;
      }

      // If we have cached user data, go to dashboard
      if (authStore.user.value != null) {
        AppSnackbars.showWarning(
          'Unable to refresh data. Using cached information',
        );
        Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));
      } else {
        // No cached data - this is a new login that failed, show error
        AppSnackbars.showError('Failed to load user data. Please try again.');
        Future.microtask(() => Get.offAllNamed(Routes.LOGIN));
      }
    }
  }

  void _handleNetworkError() {
    debugPrint('🌐 SplashController._handleNetworkError()');
    final authStore = Get.find<AuthStore>();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // If Firebase user exists, they're logged in - go to dashboard with cached data
    if (firebaseUser != null) {
      if (authStore.user.value?.blocked == true) {
        debugPrint('🚫 SplashController: User blocked, navigating to BLOCKED');
        Future.microtask(() => Get.offAllNamed(Routes.BLOCKED));
        return;
      }

      debugPrint(
        '⚠️ SplashController: Network error but user logged in, using cached data',
      );
      AppSnackbars.showWarning('No internet connection. Using cached data');
      Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));
      return;
    }

    // No Firebase user - go to login
    debugPrint(
      '⚠️ SplashController: Network error and no user, navigating to LOGIN',
    );
    Future.microtask(() => Get.offAllNamed(Routes.LOGIN));
  }
}
