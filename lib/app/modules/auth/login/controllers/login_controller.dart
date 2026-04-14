import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class LoginController extends GetxController {
  final isGoogleLoading = false.obs;
  final errorMessage = ''.obs;
  final _firebaseService = Get.find<FirebaseService>();
  final _authStore = Get.find<AuthStore>();

  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    debugPrint('🔐 LoginController.signInWithGoogle()');
    try {
      isGoogleLoading.value = true;
      errorMessage.value = '';

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        debugPrint('❌ LoginController.signInWithGoogle: Firebase user is null');
        throw Exception('Firebase authentication failed');
      }

      debugPrint(
        '✅ LoginController.signInWithGoogle: Firebase auth success (uid=${firebaseUser.uid})',
      );
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        debugPrint('❌ LoginController.signInWithGoogle: ID token is null');
        throw Exception('Failed to get ID token');
      }

      try {
        final userData = await _authStore.getCurrentUser(token: idToken);

        if (userData.blocked) {
          debugPrint('🚫 LoginController.signInWithGoogle: User blocked');
          await _authStore.setAuth(idToken, userData);
          AppSnackbars.showError('Your account has been blocked');
          Future.microtask(() => Get.offAllNamed(Routes.BLOCKED));
          return;
        }

        debugPrint(
          '✅ LoginController.signInWithGoogle: User authenticated (blocked=${userData.blocked})',
        );
        await _authStore.setAuth(idToken, userData);

        final fcmToken = await _firebaseService.getFcmToken();
        if (fcmToken != null) {
          _authStore.updateFcmToken(fcmToken).catchError((_) {});
        }

        debugPrint('✅ LoginController.signInWithGoogle: Sign in successful');
        AppSnackbars.showSuccess('Sign in successful');
        Future.microtask(() => Get.offAllNamed(Routes.DASHBOARD));
      } catch (e) {
        debugPrint('❌ LoginController.signInWithGoogle: API error: $e');
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('connection') ||
            errorMsg.contains('timeout') ||
            errorMsg.contains('network')) {
          errorMessage.value =
              'Network error. Please check your connection and try again.';
        } else if (errorMsg.contains('401') ||
            errorMsg.contains('unauthorized')) {
          errorMessage.value = 'Authentication failed. Please try again.';
        } else {
          errorMessage.value = 'Failed to sign in. Please try again.';
        }
        _firebaseService.logError(e, StackTrace.current);
        await _firebaseAuth.signOut();
      }
    } catch (e) {
      debugPrint('❌ LoginController.signInWithGoogle: Error: $e');
      errorMessage.value = 'Sign in failed. Please try again.';
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isGoogleLoading.value = false;
    }
  }
}
