import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class UpdateProfileController extends GetxController {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  final _authStore = Get.find<AuthStore>();
  final _firebaseService = Get.find<FirebaseService>();

  String _initialName = '';
  String _initialPhone = '';

  firebase_auth.User? get currentUser =>
      firebase_auth.FirebaseAuth.instance.currentUser;

  final hasChanges = false.obs;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 UpdateProfileController.onInit()');
    _loadUserData();
    nameController.addListener(_checkChanges);
    numberController.addListener(_checkChanges);
  }

  void _checkChanges() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      final currentName = nameController.text.trim();
      final currentPhone = numberController.text.trim();
      hasChanges.value =
          currentName != _initialName || currentPhone != _initialPhone;
    });
  }

  void _loadUserData() {
    final user = currentUser;
    final userData = _authStore.user.value;

    _initialName = userData?.displayName ?? user?.displayName ?? '';
    _initialPhone = userData?.phone ?? user?.phoneNumber ?? '';

    nameController.text = _initialName;
    emailController.text = userData?.email ?? user?.email ?? '';
    numberController.text = _initialPhone;

    hasChanges.value = false;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    nameController.dispose();
    numberController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    debugPrint('💾 UpdateProfileController.updateProfile()');
    try {
      isLoading.value = true;

      final user = currentUser;
      if (user == null) {
        debugPrint('❌ UpdateProfileController.updateProfile: User not found');
        AppSnackbars.showError('User not found');
        return;
      }

      final displayName = nameController.text.trim();
      final phone = numberController.text.trim();

      String? displayNameToUpdate;
      String? phoneToUpdate;

      if (displayName != _initialName) {
        displayNameToUpdate = displayName.isEmpty ? null : displayName;
      }

      if (phone != _initialPhone) {
        phoneToUpdate = phone.isEmpty ? null : phone;
      }

      if (displayNameToUpdate == null && phoneToUpdate == null) {
        debugPrint('⚠️ UpdateProfileController.updateProfile: No changes');
        AppSnackbars.showError('No changes to update');
        return;
      }

      debugPrint(
        '💾 UpdateProfileController.updateProfile: Updating (name=${displayNameToUpdate != null}, phone=${phoneToUpdate != null})',
      );

      final idToken = await user.getIdToken(true);
      if (idToken == null) {
        AppSnackbars.showError('Failed to get authentication token');
        return;
      }

      await _authStore.setAuthToken(idToken);

      final futures = <Future<void>>[
        _authStore.updateProfile(
          displayName: displayNameToUpdate,
          phone: phoneToUpdate,
        ),
      ];

      if (displayName.isNotEmpty && displayName != _initialName) {
        futures.add(user.updateDisplayName(displayName));
      }

      await Future.wait(futures);
      await user.reload();

      final refreshedToken = await user.getIdToken(true);
      if (refreshedToken != null) {
        await _authStore.getCurrentUser(token: refreshedToken);
      }

      debugPrint('✅ UpdateProfileController.updateProfile: Success');
      AppSnackbars.showSuccess('Profile updated successfully');
      Get.back();
    } catch (e) {
      debugPrint('❌ UpdateProfileController.updateProfile error: $e');
      _firebaseService.logError(e, StackTrace.current);
      AppSnackbars.showError('Failed to update profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
