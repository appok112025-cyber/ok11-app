import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/repositories/submission_repository.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class MyMatchesController extends GetxController {
  final _submissionRepository = SubmissionRepository();
  final _firebaseService = Get.find<FirebaseService>();
  final selectedTab = 0.obs;
  final isLoading = true.obs;

  final upcomingMatches = <MatchData>[].obs;
  final liveMatches = <MatchData>[].obs;
  final completedMatches = <MatchData>[].obs;
  final currentMatches = <MatchData>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 MyMatchesController.onInit()');
    _firebaseService.setScreenContext(Routes.DASHBOARD);
    Future.microtask(() => loadMatches());
    ever(selectedTab, (_) => _updateCurrentMatches());
  }

  Future<void> loadMatches() async {
    debugPrint('📥 MyMatchesController.loadMatches()');
    isLoading.value = true;
    try {
      final allSubmissions = await _submissionRepository.getUserSubmissions();

      upcomingMatches.value = allSubmissions
          .where((match) => match.status == MatchStatus.upcoming)
          .toList();

      liveMatches.value = allSubmissions
          .where((match) => match.status == MatchStatus.live)
          .toList();

      completedMatches.value = allSubmissions
          .where((match) => match.status == MatchStatus.completed)
          .toList();

      _updateCurrentMatches();
      debugPrint(
        '✅ MyMatchesController.loadMatches: upcoming=${upcomingMatches.length}, live=${liveMatches.length}, completed=${completedMatches.length}',
      );
      _firebaseService.logBreadcrumb(
        'My matches loaded',
        data: {
          'upcoming': upcomingMatches.length,
          'live': liveMatches.length,
          'completed': completedMatches.length,
        },
      );
    } catch (e) {
      debugPrint('❌ MyMatchesController.loadMatches error: $e');
      AppSnackbars.showError('Failed to load matches');
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChanged(int index) {
    debugPrint('🔄 MyMatchesController.onTabChanged: $index');
    selectedTab.value = index;
  }

  Future<void> refreshMatches() async {
    debugPrint('🔄 MyMatchesController.refreshMatches()');
    try {
      final allSubmissions = await _submissionRepository.getUserSubmissions();

      upcomingMatches.value = allSubmissions
          .where((match) => match.status == MatchStatus.upcoming)
          .toList();

      liveMatches.value = allSubmissions
          .where((match) => match.status == MatchStatus.live)
          .toList();

      completedMatches.value = allSubmissions
          .where((match) => match.status == MatchStatus.completed)
          .toList();

      _updateCurrentMatches();
      debugPrint(
        '✅ MyMatchesController.refreshMatches: upcoming=${upcomingMatches.length}, live=${liveMatches.length}, completed=${completedMatches.length}',
      );
      _firebaseService.logBreadcrumb(
        'My matches refreshed',
        data: {
          'upcoming': upcomingMatches.length,
          'live': liveMatches.length,
          'completed': completedMatches.length,
        },
      );
    } catch (e) {
      debugPrint('❌ MyMatchesController.refreshMatches error: $e');
      _firebaseService.logError(e, StackTrace.current);
      rethrow;
    }
  }

  void _updateCurrentMatches() {
    debugPrint(
      '🔄 MyMatchesController._updateCurrentMatches: tab=${selectedTab.value}',
    );
    switch (selectedTab.value) {
      case 0:
        currentMatches.assignAll(upcomingMatches.toList());
        break;
      case 1:
        currentMatches.assignAll(liveMatches.toList());
        break;
      case 2:
        currentMatches.assignAll(completedMatches.toList());
        break;
      default:
        currentMatches.assignAll(upcomingMatches.toList());
    }
    debugPrint(
      '✅ MyMatchesController._updateCurrentMatches: ${currentMatches.length} matches',
    );
  }
}
