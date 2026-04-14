import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/app_services.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/stores/auth_store.dart' as auth_store;
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class ProfileController extends GetxController {
  final _firebaseService = Get.find<FirebaseService>();
  final _authStore = Get.find<auth_store.AuthStore>();

  User? get currentUser => FirebaseAuth.instance.currentUser;
  auth_store.User? get userData => _authStore.user.value;

  String get appVersion => Get.find<AppServices>().appVersion.value;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 ProfileController.onInit()');
    _firebaseService.setScreenContext(Routes.PROFILE);
  }

  Future<void> logout() async {
    debugPrint('🚪 ProfileController.logout()');
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ ProfileController.logout: Success');
      _firebaseService.logBreadcrumb('User logged out');
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint('❌ ProfileController.logout error: $e');
      AppSnackbars.showError('Failed to logout');
      _firebaseService.logError(e, StackTrace.current);
    }
  }
}
