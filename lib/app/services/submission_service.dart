import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/repositories/submission_repository.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/stores/auth_store.dart';

class SubmissionService extends GetxService {
  final _submissionRepository = SubmissionRepository();
  final _firebaseService = Get.find<FirebaseService>();

  final submittedMatchIds = <String>{}.obs;

  /// Check if user is authenticated before making API calls
  bool get _isAuthenticated {
    if (!Get.isRegistered<AuthStore>()) return false;
    final authStore = Get.find<AuthStore>();
    return authStore.isAuthenticated.value && authStore.user.value != null;
  }

  Future<SubmissionService> init() async {
    // Don't call refreshSubmissions() here - it requires authentication
    // The HomeController will call it after user is authenticated
    return this;
  }

  Future<void> refreshSubmissions() async {
    // Skip API call if user is not authenticated
    if (!_isAuthenticated) {
      debugPrint(
        '⚠️ SubmissionService.refreshSubmissions: Skipped - user not authenticated',
      );
      submittedMatchIds.clear();
      return;
    }

    debugPrint('🔄 SubmissionService.refreshSubmissions()');
    try {
      final submittedIds = await _submissionRepository
          .getUserSubmittedMatchIds();
      submittedMatchIds.clear();
      submittedMatchIds.addAll(submittedIds);
      debugPrint(
        '✅ SubmissionService: ${submittedIds.length} submitted matches loaded',
      );

      // Subscribe to topics for all submitted matches to receive result notifications
      for (final matchId in submittedIds) {
        await _firebaseService.subscribeToMatch(matchId);
      }
    } catch (e) {
      debugPrint('❌ SubmissionService.refreshSubmissions error: $e');
      _firebaseService.logError(e, StackTrace.current);
    }
  }

  void addSubmission(String matchId) {
    if (!submittedMatchIds.contains(matchId)) {
      submittedMatchIds.add(matchId);
      debugPrint('✅ SubmissionService: Added matchId=$matchId');
      // Subscribe to match topic for result notifications
      _firebaseService.subscribeToMatch(matchId);
    }
  }

  void removeSubmission(String matchId) {
    if (submittedMatchIds.contains(matchId)) {
      submittedMatchIds.remove(matchId);
      debugPrint('✅ SubmissionService: Removed matchId=$matchId');
      // Unsubscribe from match topic
      _firebaseService.unsubscribeFromMatch(matchId);
    }
  }

  bool hasUserSubmitted(String? matchId) {
    if (matchId == null) return false;
    return submittedMatchIds.contains(matchId);
  }
}
