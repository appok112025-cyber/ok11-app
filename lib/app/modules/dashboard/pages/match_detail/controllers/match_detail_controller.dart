import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/quiz_question.dart';
import 'package:ok11/app/data/models/submission_data.dart';

import 'package:ok11/app/data/repositories/match_repository.dart';
import 'package:ok11/app/data/repositories/submission_repository.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/services/firebase_service.dart';
import 'package:ok11/app/services/submission_service.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';

class MatchDetailController extends GetxController {
  /// Dream11 style: exactly 11 players TOTAL across both teams
  static const int maxTotalPlayers = 11;

  final _submissionRepository = SubmissionRepository();
  final _matchRepository = MatchRepository();
  final _firebaseService = Get.find<FirebaseService>();
  final _authStore = Get.find<AuthStore>();
  final _submissionService = Get.find<SubmissionService>();

  final selectedTab = 0.obs;
  final isLoadingQuiz = false.obs;
  final isLoadingScore = false.obs;
  final isLoadingSubmission = false.obs;
  final hasSubmitted = false.obs;
  final squadExpanded = false.obs;
  final quizExpanded = false.obs;

  final matchData = Rxn<MatchData>();
  final submissionData = Rxn<SubmissionData>();
  final selectedTeam1Players = <String>{}.obs;
  final selectedTeam2Players = <String>{}.obs;
  final selectedQuizAnswers = <String, int>{}.obs;

  Map<String, String>? _team1PlayerIdToName;
  Map<String, String>? _team2PlayerIdToName;
  Map<String, String>? _team1PlayerNameToId;
  Map<String, String>? _team2PlayerNameToId;

  List<QuizQuestion> get questions {
    return matchData.value?.quizzes ?? [];
  }

  /// Total selected players across both teams
  int get totalSelectedPlayers =>
      selectedTeam1Players.length + selectedTeam2Players.length;

  /// How many more players can be selected
  int get remainingSlots => maxTotalPlayers - totalSelectedPlayers;

  /// Whether the squad is complete (exactly 11 selected)
  bool get isSquadComplete {
    if (Get.isRegistered<ContestController>()) {
      return Get.find<ContestController>().isTeamValid;
    }
    return totalSelectedPlayers == maxTotalPlayers;
  }

  void togglePlayerSelection(String playerName, String team) {
    if (team == 'team1') {
      if (selectedTeam1Players.contains(playerName)) {
        selectedTeam1Players.remove(playerName);
        debugPrint(
          '👤 Removed $playerName from team1 (total: $totalSelectedPlayers/$maxTotalPlayers)',
        );
      } else {
        // Check TOTAL combined limit (Dream11 style)
        if (totalSelectedPlayers >= maxTotalPlayers) {
          debugPrint(
            '⚠️ Cannot add $playerName: Total limit ($maxTotalPlayers) reached',
          );
          AppSnackbars.showError(
            'You can only select $maxTotalPlayers players total',
          );
          return;
        }
        selectedTeam1Players.add(playerName);
        debugPrint(
          '👤 Added $playerName to team1 (total: $totalSelectedPlayers/$maxTotalPlayers)',
        );
      }
    } else {
      if (selectedTeam2Players.contains(playerName)) {
        selectedTeam2Players.remove(playerName);
        debugPrint(
          '👤 Removed $playerName from team2 (total: $totalSelectedPlayers/$maxTotalPlayers)',
        );
      } else {
        // Check TOTAL combined limit (Dream11 style)
        if (totalSelectedPlayers >= maxTotalPlayers) {
          debugPrint(
            '⚠️ Cannot add $playerName: Total limit ($maxTotalPlayers) reached',
          );
          AppSnackbars.showError(
            'You can only select $maxTotalPlayers players total',
          );
          return;
        }
        selectedTeam2Players.add(playerName);
        debugPrint(
          '👤 Added $playerName to team2 (total: $totalSelectedPlayers/$maxTotalPlayers)',
        );
      }
    }
  }

  bool isPlayerSelected(String playerName, String team) {
    if (team == 'team1') {
      return selectedTeam1Players.contains(playerName);
    } else {
      return selectedTeam2Players.contains(playerName);
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 MatchDetailController.onInit()');

    // Set up notification refresh callback for real-time match updates
    _firebaseService.onNotificationReceived = _handleNotificationRefresh;

    final arguments = Get.arguments;
    if (arguments is MatchData) {
      matchData.value = arguments;
      _buildPlayerLookupMaps(arguments);
      
      // Initialize ContestController early to avoid "setState during build" errors
      if (!Get.isRegistered<ContestController>()) {
        Get.put(ContestController()).setupForMatch(arguments);
      } else {
        Get.find<ContestController>().setupForMatch(arguments);
      }

      debugPrint(
        '📋 Match: ${arguments.id} | ${arguments.title} | Players: ${arguments.team1Players.length}/${arguments.team2Players.length} | Quizzes: ${arguments.quizzes.length}',
      );
      for (int i = 0; i < arguments.quizzes.length; i++) {
        final quiz = arguments.quizzes[i];
        debugPrint(
          '📝 Quiz[$i]: quizId=${quiz.quizId} | question="${quiz.question}" | options=${quiz.options.length}',
        );
      }

      // Check if submission exists immediately (O(1) lookup)
      if (arguments.id != null &&
          _submissionService.hasUserSubmitted(arguments.id)) {
        debugPrint('✅ Submission exists');
      }

      // Load contest data and prefill squad if the user already joined
      if (arguments.id != null) {
        // Trigger a background refresh to get latest player roles/images
        _refreshMatchData();
        
        Future.microtask(() async {
          final contestCtrl = Get.find<ContestController>();
          await contestCtrl.fetchContests(arguments.id!);
          
          if (contestCtrl.joinedContestIds.isNotEmpty) {
            debugPrint('🏆 Already joined contests found');
          }
          
          loadSubmission(); // Keep this for quiz answers if still needed
        });
      }
    } else {
      debugPrint('⚠️ Invalid arguments: ${arguments.runtimeType}');
    }
    _firebaseService.setScreenContext(Routes.MATCH_DETAIL);
  }

  @override
  void onClose() {
    // Clean up notification callback when controller is disposed
    _firebaseService.onNotificationReceived = null;
    super.onClose();
  }

  /// Handle notification-triggered refresh for real-time match updates
  void _handleNotificationRefresh(String type, Map<String, dynamic> data) {
    debugPrint('🔔 MatchDetailController: Notification received - type=$type');

    final currentMatchId = matchData.value?.id;
    final notificationMatchId = data['matchId'] as String?;

    // Check if this notification is for the current match
    if (type == 'match_updated' ||
        type == 'match_live' ||
        type == 'match_completed') {
      if (notificationMatchId == null ||
          notificationMatchId == currentMatchId) {
        debugPrint('🔄 MatchDetailController: Refreshing match data');
        _refreshMatchData();
      }
    }
  }

  /// Refresh the current match data from API
  Future<void> _refreshMatchData() async {
    final currentMatchId = matchData.value?.id;
    if (currentMatchId == null) return;

    debugPrint('📥 MatchDetailController: Refreshing match $currentMatchId');
    try {
      final updatedMatch = await _matchRepository.getMatchById(currentMatchId);
      if (updatedMatch != null) {
        // Update match data while preserving user selections
        final oldStatus = matchData.value?.status;
        matchData.value = updatedMatch;
        _buildPlayerLookupMaps(updatedMatch);
        
        // Update ContestController with latest player data
        if (Get.isRegistered<ContestController>()) {
          Get.find<ContestController>().setupForMatch(updatedMatch);
        }

        debugPrint(
          '✅ MatchDetailController: Match refreshed | status: $oldStatus → ${updatedMatch.status}',
        );

        // If match status changed to live or completed, reload submission data
        if (updatedMatch.status == MatchStatus.live ||
            updatedMatch.status == MatchStatus.completed) {
          await loadSubmission();
        }
      }
    } catch (e) {
      debugPrint('❌ MatchDetailController: Failed to refresh match: $e');
      _firebaseService.logError(e, StackTrace.current);
    }
  }

  void _buildPlayerLookupMaps(MatchData match) {
    _team1PlayerIdToName = {
      for (var player in match.team1PlayerData) player.id: player.name,
    };
    _team2PlayerIdToName = {
      for (var player in match.team2PlayerData) player.id: player.name,
    };
    _team1PlayerNameToId = {
      for (var player in match.team1PlayerData) player.name: player.id,
    };
    _team2PlayerNameToId = {
      for (var player in match.team2PlayerData) player.name: player.id,
    };
  }

  Future<void> loadSubmission() async {
    final match = matchData.value;
    if (match?.id == null) {
      debugPrint('⚠️ loadSubmission: No match ID');
      return;
    }

    debugPrint('📥 loadSubmission: matchId=${match!.id}');
    isLoadingSubmission.value = true;
    try {
      final submission = await _submissionRepository.getUserSubmissionForMatch(
        match.id!,
      );
      if (submission != null) {
        debugPrint(
          '✅ loadSubmission: Found submission ${submission.id ?? 'unknown'} | Player: ${submission.selectedPlayer ?? 'none'} | Answers: ${submission.quizAnswers?.length ?? 0}',
        );
        submissionData.value = submission;
        hasSubmitted.value = true;
        // Pre-fill submission data
        _loadSubmissionData(submission);
      } else {
        debugPrint('ℹ️ loadSubmission: No submission found');
      }
    } catch (e) {
      debugPrint('❌ loadSubmission error: $e');
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoadingSubmission.value = false;
    }
  }

  void _loadSubmissionData(SubmissionData submission) {
    debugPrint('🔄 _loadSubmissionData: Loading submission data');
    final match = matchData.value;
    if (match != null &&
        _team1PlayerIdToName != null &&
        _team2PlayerIdToName != null) {
      // Handle new format (arrays) - O(n) instead of O(n*m)
      if ((submission.teamASelectedPlayers?.isNotEmpty ?? false) ||
          (submission.teamBSelectedPlayers?.isNotEmpty ?? false)) {
        for (var playerId in submission.teamASelectedPlayers ?? []) {
          final playerName = _team1PlayerIdToName![playerId];
          if (playerName != null &&
              !selectedTeam1Players.contains(playerName)) {
            selectedTeam1Players.add(playerName);
            debugPrint('👤 Pre-filled team1: $playerName');
          }
        }
        for (var playerId in submission.teamBSelectedPlayers ?? []) {
          final playerName = _team2PlayerIdToName![playerId];
          if (playerName != null &&
              !selectedTeam2Players.contains(playerName)) {
            selectedTeam2Players.add(playerName);
            debugPrint('👤 Pre-filled team2: $playerName');
          }
        }
      }
      // Fall back to old format (single selectedPlayer)
      else if ((submission.selectedPlayer?.isNotEmpty ?? false) &&
          submission.selectedPlayer != null) {
        final team1Set = match.team1Players.toSet();
        final team2Set = match.team2Players.toSet();
        if (team1Set.contains(submission.selectedPlayer!)) {
          selectedTeam1Players.add(submission.selectedPlayer!);
          debugPrint('👤 Pre-filled team1: ${submission.selectedPlayer}');
        } else if (team2Set.contains(submission.selectedPlayer!)) {
          selectedTeam2Players.add(submission.selectedPlayer!);
          debugPrint('👤 Pre-filled team2: ${submission.selectedPlayer}');
        }
      }
    }

    int answersLoaded = 0;
    final quizAnswers = submission.quizAnswers ?? [];
    for (int i = 0; i < quizAnswers.length && i < questions.length; i++) {
      final answer = quizAnswers[i];
      final questionId = 'quiz_$i';
      final selectedOption = answer.selectedOption;
      if (selectedOption != null) {
        selectedQuizAnswers[questionId] = selectedOption;
        answersLoaded++;
      }
    }
    debugPrint(
      '📝 Pre-filled quiz answers: $answersLoaded/${questions.length}',
    );
  }

  Future<void> loadQuizData() async {
    debugPrint('📚 loadQuizData: Questions=${questions.length}');
    isLoadingQuiz.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('✅ loadQuizData: Complete');
    } catch (e) {
      debugPrint('❌ loadQuizData error: $e');
      AppSnackbars.showError('Failed to load quiz data');
    } finally {
      isLoadingQuiz.value = false;
    }
  }

  void selectQuizAnswer(String questionId, int optionIndex) {
    selectedQuizAnswers[questionId] = optionIndex;
    debugPrint(
      '📝 Quiz answer: $questionId → option $optionIndex (${selectedQuizAnswers.length}/${questions.length})',
    );
  }

  int? getSelectedAnswer(String questionId) {
    return selectedQuizAnswers[questionId];
  }

  Future<void> loadScoreData() async {
    debugPrint('📊 loadScoreData: Starting');
    isLoadingScore.value = true;
    try {
      final match = matchData.value;
      if (match?.id != null) {
        final hasSubmission =
            selectedTeam1Players.isNotEmpty &&
            selectedTeam2Players.isNotEmpty &&
            selectedQuizAnswers.length >= questions.length;

        hasSubmitted.value =
            _submissionService.hasUserSubmitted(match?.id) || hasSubmission;
        debugPrint(
          '📊 loadScoreData: hasSubmitted=${hasSubmitted.value} (local=$hasSubmission, service=${_submissionService.hasUserSubmitted(match?.id)})',
        );

        if (match?.status == MatchStatus.completed && hasSubmitted.value) {
          debugPrint('📊 loadScoreData: Match completed, loading submission');
          // Load submission data which contains the score
          await loadSubmission();
          debugPrint('✅ loadScoreData: Submission loaded with score');
        } else {
          debugPrint(
            'ℹ️ loadScoreData: Match not completed or no submission (status=${match?.status}, hasSubmitted=${hasSubmitted.value})',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ loadScoreData error: $e');
      AppSnackbars.showError('Failed to load score data');
    } finally {
      isLoadingScore.value = false;
    }
  }

  bool get isWaitingForResults {
    final match = matchData.value;
    return hasSubmitted.value &&
        match != null &&
        match.status != MatchStatus.completed;
  }

  bool get canAccessQuiz {
    // Dream11 style: must select exactly 11 total players
    return isSquadComplete;
  }

  bool get canAccessScore {
    if (questions.isEmpty) return true;
    return selectedQuizAnswers.length >= questions.length;
  }

  void onTabChanged(int index) {
    debugPrint(
      '🔀 onTabChanged: $index (current: ${selectedTab.value}) | canAccessQuiz=$canAccessQuiz | canAccessScore=$canAccessScore',
    );
    if (index == 1) {
      // Allow unrestricted access to the Contest tab (Tab 1)
      // Squad validation now happens when user clicks "Join Contest"
    }
    if (index == 2) {
      // Allow unrestricted access to the Leaderboard tab (Tab 2)
      // Quiz is no longer required to view the leaderboard.
    }

    if (index > selectedTab.value) {
      // No tab restrictions
    }

    selectedTab.value = index;
    debugPrint('✅ onTabChanged: Tab changed to $index');
    if (index == 1 && questions.isEmpty && !isLoadingQuiz.value) {
      loadQuizData();
    } else if (index == 2 && !isLoadingScore.value) {
      loadScoreData();
    }
  }

  Future<void> saveSquad() async {
    debugPrint(
      '💾 saveSquad: Team1=${selectedTeam1Players.length} | Team2=${selectedTeam2Players.length} | Total=$totalSelectedPlayers/$maxTotalPlayers',
    );

    if (!isSquadComplete) {
      AppSnackbars.showError(
        'Please select exactly $maxTotalPlayers players ($totalSelectedPlayers/$maxTotalPlayers selected)',
      );
      return;
    }

    onTabChanged(0);
  }

  Future<void> saveQuiz() async {
    debugPrint(
      '💾 saveQuiz: Starting | Answers=${selectedQuizAnswers.length}/${questions.length}',
    );
    isLoadingQuiz.value = true;
    try {
      final match = matchData.value;
      if (match?.id == null) {
        debugPrint('❌ saveQuiz: No match data');
        AppSnackbars.showError('Match data not available');
        return;
      }

      if (!isSquadComplete) {
        debugPrint('❌ saveQuiz: Squad not complete ($totalSelectedPlayers/$maxTotalPlayers)');
        AppSnackbars.showError(
          'Please select exactly $maxTotalPlayers players',
        );
        return;
      }

      // Get userId from auth store
      final userId = _authStore.user.value?.id;
      if (userId == null || userId.isEmpty) {
        debugPrint('❌ saveQuiz: No user ID');
        AppSnackbars.showError('User not authenticated');
        return;
      }

      // Convert player names to player IDs - O(n) instead of O(n*m)
      final teamASelectedPlayerIds = <String>[];
      if (_team1PlayerNameToId != null) {
        for (var playerName in selectedTeam1Players) {
          final playerId = _team1PlayerNameToId![playerName];
          if (playerId != null) {
            teamASelectedPlayerIds.add(playerId);
          }
        }
      }

      final teamBSelectedPlayerIds = <String>[];
      if (_team2PlayerNameToId != null) {
        for (var playerName in selectedTeam2Players) {
          final playerId = _team2PlayerNameToId![playerName];
          if (playerId != null) {
            teamBSelectedPlayerIds.add(playerId);
          }
        }
      }

      debugPrint(
        '👤 saveQuiz: userId=$userId | teamA=${teamASelectedPlayerIds.length} players | teamB=${teamBSelectedPlayerIds.length} players',
      );

      if (selectedQuizAnswers.length < questions.length) {
        debugPrint(
          '❌ saveQuiz: Incomplete answers (${selectedQuizAnswers.length}/${questions.length})',
        );
        AppSnackbars.showError('Please answer all quiz questions');
        return;
      }

      final quizAnswers = <Map<String, dynamic>>[];
      debugPrint('🔍 saveQuiz: Processing ${questions.length} questions');
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final questionId = 'quiz_$i';
        final selectedIndex = selectedQuizAnswers[questionId];

        debugPrint(
          '🔍 saveQuiz: Question[$i] | questionId=$questionId | quizId=${question.quizId} | selectedIndex=$selectedIndex',
        );

        if (selectedIndex == null) {
          debugPrint('❌ saveQuiz: Missing answer for question ${i + 1}');
          AppSnackbars.showError('Please answer question ${i + 1}');
          return;
        }

        final quizId = question.quizId;
        if (quizId == null || quizId.isEmpty) {
          debugPrint('❌ saveQuiz: Missing quizId for question ${i + 1}');
          AppSnackbars.showError(
            'Quiz ID missing for question ${i + 1}. Please refresh and try again.',
          );
          return;
        }
        debugPrint(
          '🔍 saveQuiz: Validating quizId | value="$quizId" | length=${quizId.length} | isValid=${_isValidObjectId(quizId)}',
        );
        if (!_isValidObjectId(quizId)) {
          debugPrint('❌ saveQuiz: Invalid quizId format: $quizId');
          AppSnackbars.showError(
            'Invalid quiz ID format for question ${i + 1}. Got: $quizId',
          );
          return;
        }
        quizAnswers.add({'quizId': quizId, 'selectedOption': selectedIndex});
        debugPrint(
          '✅ saveQuiz: Added answer[$i] | quizId=$quizId | option=$selectedIndex',
        );
      }

      final matchId = match!.id!;
      debugPrint(
        '📤 saveQuiz: POST submission | userId=$userId | matchId=$matchId | teamA=${teamASelectedPlayerIds.length} | teamB=${teamBSelectedPlayerIds.length} | answers=${quizAnswers.length}',
      );
      final submission = await _submissionRepository.createOrUpdateSubmission(
        userId: userId,
        matchId: matchId,
        teamASelectedPlayers: teamASelectedPlayerIds,
        teamBSelectedPlayers: teamBSelectedPlayerIds,
        quizAnswers: quizAnswers,
      );

      if (submission != null) {
        debugPrint('✅ saveQuiz: Submission saved | id=${submission.id}');
        submissionData.value = submission;
        hasSubmitted.value = true;
        AppSnackbars.showSuccess('Submission saved successfully');
        _firebaseService.logBreadcrumb('Submission saved');

        _submissionService.addSubmission(matchId);

        onTabChanged(2);
      } else {
        debugPrint('❌ saveQuiz: Submission failed - null response');
        AppSnackbars.showError('Failed to save submission');
      }
    } catch (e) {
      debugPrint('❌ saveQuiz error: $e');
      AppSnackbars.showError('Failed to save quiz: ${e.toString()}');
      _firebaseService.logError(e, StackTrace.current);
    } finally {
      isLoadingQuiz.value = false;
    }
  }

  bool _isValidObjectId(String id) {
    // MongoDB ObjectId is 24 hex characters
    return id.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
  }
}
