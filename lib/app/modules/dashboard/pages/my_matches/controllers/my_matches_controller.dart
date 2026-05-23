import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/repositories/submission_repository.dart';
import 'package:ok11/app/data/repositories/contest_repository.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class MyMatchesController extends GetxController {
  final _submissionRepository = SubmissionRepository();
  final _contestRepository = ContestRepository();
  final _firebaseService = Get.find<FirebaseService>();
  final selectedTab = 0.obs;
  final isLoading = true.obs;

  final upcomingMatches = <MyJoinedItem>[].obs;
  final liveMatches = <MyJoinedItem>[].obs;
  final completedMatches = <MyJoinedItem>[].obs;
  final currentMatches = <MyJoinedItem>[].obs;

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
      // Fetch both quiz submissions and contest entries
      final results = await Future.wait([
        _submissionRepository.getUserSubmissions(),
        _contestRepository.getAllJoinedMatches(),
      ]);

      final List<MatchData> quizSubmissions = results[0] as List<MatchData>;
      final List<MyJoinedItem> contestItems = results[1] as List<MyJoinedItem>;

      final List<MyJoinedItem> allItems = List<MyJoinedItem>.from(contestItems);
      
      final Set<String> contestMatchIds = contestItems
          .map((item) => item.match.id)
          .whereType<String>()
          .toSet();

      for (var m in quizSubmissions) {
        if (m.id != null && !contestMatchIds.contains(m.id)) {
          allItems.add(MyJoinedItem(match: m));
        }
      }

      upcomingMatches.value = allItems
          .where((item) => item.match.status == MatchStatus.upcoming)
          .toList();

      liveMatches.value = allItems
          .where((item) => item.match.status == MatchStatus.live)
          .toList();

      completedMatches.value = allItems
          .where((item) => item.match.status == MatchStatus.completed)
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
      final results = await Future.wait([
        _submissionRepository.getUserSubmissions(),
        _contestRepository.getAllJoinedMatches(),
      ]);

      final List<MatchData> quizSubmissions = results[0] as List<MatchData>;
      final List<MyJoinedItem> contestItems = results[1] as List<MyJoinedItem>;

      final List<MyJoinedItem> allItems = List<MyJoinedItem>.from(contestItems);
      
      final Set<String> contestMatchIds = contestItems
          .map((item) => item.match.id)
          .whereType<String>()
          .toSet();

      for (var m in quizSubmissions) {
        if (m.id != null && !contestMatchIds.contains(m.id)) {
          allItems.add(MyJoinedItem(match: m));
        }
      }

      upcomingMatches.value = allItems
          .where((item) => item.match.status == MatchStatus.upcoming)
          .toList();

      liveMatches.value = allItems
          .where((item) => item.match.status == MatchStatus.live)
          .toList();

      completedMatches.value = allItems
          .where((item) => item.match.status == MatchStatus.completed)
          .toList();

      _updateCurrentMatches();
      debugPrint(
        '✅ MyMatchesController.refreshMatches: upcoming=${upcomingMatches.length}, live=${liveMatches.length}, completed=${completedMatches.length}',
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
      '✅ MyMatchesController._updateCurrentMatches: ${currentMatches.length} items',
    );
  }
}
