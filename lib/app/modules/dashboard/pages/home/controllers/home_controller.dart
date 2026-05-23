import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/repositories/match_repository.dart';
import 'package:ok11/app/data/repositories/contest_repository.dart';
import 'package:ok11/app/modules/dashboard/pages/my_matches/controllers/my_matches_controller.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/services/submission_service.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class HomeController extends GetxController {
  final _repository = MatchRepository();
  final _firebaseService = Get.find<FirebaseService>();
  final _submissionService = Get.find<SubmissionService>();
  final isLoading = true.obs;

  // Reactive Wallet Balance
  final walletBalance = 0.0.obs;

  // Withdraw from Wallet (Minimum 1000)
  void withdraw(double amount) {
    if (walletBalance.value < 1000) {
      Get.snackbar(
        'Withdrawal Failed',
        'Minimum withdrawal amount is ₹1,000',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    if (walletBalance.value < amount) {
      Get.snackbar(
        'Withdrawal Failed',
        'Insufficient balance',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    walletBalance.value -= amount;
    Get.snackbar(
      'Withdrawal Successful',
      '₹${amount.toInt()} withdrawal initiated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF43A047),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  // Upcoming matches only
  final matches = <MatchData>[].obs;

  /// Check if there are any matches
  bool get hasMatches => matches.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 HomeController.onInit()');
    _firebaseService.setScreenContext(Routes.HOME);

    // Set up notification refresh callback for real-time updates
    _firebaseService.onNotificationReceived = _handleNotificationRefresh;

    // Load matches with 0ms visual load
    Future.microtask(() async {
      await _repository.initCache();
      final cached = _repository.getInMemoryUpcomingMatches();
      if (cached.isNotEmpty) {
        matches.value = _sortMatches(cached);
        isLoading.value = false; // Render instantly from cache
        debugPrint('⚡ HomeController: Visual load completed in 0ms using cache');
      }
      await loadMatches();
    });
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('🔄 HomeController.onReady() - Refreshing submissions');
    Future.microtask(() => _submissionService.refreshSubmissions());
  }

  @override
  void onClose() {
    // Clean up notification callback when controller is disposed
    _firebaseService.onNotificationReceived = null;
    super.onClose();
  }

  /// Handle notification-triggered refresh for real-time updates
  void _handleNotificationRefresh(String type, Map<String, dynamic> data) {
    debugPrint('🔔 HomeController: Notification received - type=$type');

    // Refresh all matches data for any notification type
    _refreshAllMatchesData();
  }

  /// Refresh all matches data from Home and MyMatches controllers
  Future<void> _refreshAllMatchesData() async {
    debugPrint('🔄 HomeController: Refreshing all matches data');

    // Refresh home matches
    refreshMatches();

    // Refresh submissions
    _submissionService.refreshSubmissions();

    // Refresh MyMatchesController if it's registered
    if (Get.isRegistered<MyMatchesController>()) {
      try {
        final myMatchesController = Get.find<MyMatchesController>();
        myMatchesController.refreshMatches();
        debugPrint('✅ HomeController: MyMatchesController refreshed');
      } catch (e) {
        debugPrint(
          '⚠️ HomeController: Failed to refresh MyMatchesController: $e',
        );
      }
    }
  }

  Future<void> loadMatches() async {
    debugPrint('📥 HomeController.loadMatches()');
    if (matches.isEmpty) {
      isLoading.value = true;
    }
    try {
      final loadedMatches = await _repository.getUpcomingMatches();
      
      // Filter matches by active contest in parallel
      final contestRepo = ContestRepository();
      final filteredMatches = <MatchData>[];
      
      await Future.wait(loadedMatches.map((match) async {
        if (match.id != null) {
          final contests = await contestRepo.getContestsForMatch(match.id!);
          final hasContest = contests.isNotEmpty;
          if (hasContest) {
            filteredMatches.add(match);
          }
        }
      }));

      matches.value = _sortMatches(filteredMatches);
      await _repository.cacheUpcomingMatches(filteredMatches);
      debugPrint(
        '✅ HomeController.loadMatches: ${matches.length} upcoming matches with contests (out of ${loadedMatches.length} raw matches)',
      );

      await _submissionService.refreshSubmissions();

      _firebaseService.logBreadcrumb(
        'Matches loaded',
        data: {'count': matches.length},
      );
    } catch (e) {
      debugPrint('❌ HomeController.loadMatches error: $e');
      if (matches.isEmpty) {
        AppSnackbars.showError('Failed to load matches');
      }
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMatches() async {
    debugPrint('🔄 HomeController.refreshMatches()');
    try {
      final loadedMatches = await _repository.getUpcomingMatches();
      
      // Filter matches by active contest in parallel
      final contestRepo = ContestRepository();
      final filteredMatches = <MatchData>[];
      
      await Future.wait(loadedMatches.map((match) async {
        if (match.id != null) {
          final contests = await contestRepo.getContestsForMatch(match.id!);
          final hasContest = contests.isNotEmpty;
          if (hasContest) {
            filteredMatches.add(match);
          }
        }
      }));

      matches.value = _sortMatches(filteredMatches);
      await _repository.cacheUpcomingMatches(filteredMatches);
      debugPrint(
        '✅ HomeController.refreshMatches: ${matches.length} upcoming matches with contests (out of ${loadedMatches.length} raw matches)',
      );

      await _submissionService.refreshSubmissions();

      _firebaseService.logBreadcrumb(
        'Matches refreshed',
        data: {'count': matches.length},
      );
    } catch (e) {
      debugPrint('❌ HomeController.refreshMatches error: $e');
      _firebaseService.logError(e, StackTrace.current);
      rethrow;
    }
  }

  bool hasUserSubmitted(String? matchId) {
    return _submissionService.hasUserSubmitted(matchId);
  }

  List<MatchData> _sortMatches(List<MatchData> matchesList) {
    final now = DateTime.now();

    final sorted = List<MatchData>.from(matchesList);
    sorted.sort((a, b) {
      final aIsToday = a.date == 'Today';
      final bIsToday = b.date == 'Today';

      if (aIsToday && !bIsToday) return -1;
      if (!aIsToday && bIsToday) return 1;

      if (aIsToday && bIsToday) {
        return _parseTime(a.time).compareTo(_parseTime(b.time));
      }

      final aDate = _parseDate(a.date, now);
      final bDate = _parseDate(b.date, now);
      final dateCompare = aDate.compareTo(bDate);
      if (dateCompare != 0) return dateCompare;

      return _parseTime(a.time).compareTo(_parseTime(b.time));
    });

    return sorted;
  }

  DateTime _parseDate(String dateStr, DateTime now) {
    if (dateStr == 'Today') {
      return DateTime(now.year, now.month, now.day);
    } else if (dateStr == 'Tomorrow') {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    } else if (dateStr == 'Yesterday') {
      final yesterday = now.subtract(const Duration(days: 1));
      return DateTime(yesterday.year, yesterday.month, yesterday.day);
    } else {
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final yearStr = parts[2];
          final year = 2000 + int.parse(yearStr);
          return DateTime(year, month, day);
        }
      } catch (e) {
        debugPrint('⚠️ HomeController._parseDate error: $e');
      }
      return DateTime.now();
    }
  }

  int _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length == 2) {
        final timePart = parts[0];
        final period = parts[1].toLowerCase();
        final timeParts = timePart.split(':');
        if (timeParts.length == 2) {
          var hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          if (period == 'pm' && hour != 12) {
            hour += 12;
          } else if (period == 'am' && hour == 12) {
            hour = 0;
          }

          return hour * 60 + minute;
        }
      }
    } catch (e) {
      debugPrint('⚠️ HomeController._parseTime error: $e');
    }
    return 0;
  }
}
