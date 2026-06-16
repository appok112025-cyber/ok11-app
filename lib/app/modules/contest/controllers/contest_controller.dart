import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/repositories/contest_repository.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class ContestController extends GetxController {
  final ContestRepository repo = ContestRepository();
  final AuthStore authStore = Get.find<AuthStore>();

  final isLoading = false.obs;
  final isJoining = false.obs;

  final contests = <ContestModel>[].obs;
  final leaderboard = <LeaderboardEntryModel>[].obs;

  // All enriched player info for the current match
  final allPlayerInfo = <PlayerInfo>[].obs;

  // Active role tab filter (null = show all)
  final Rx<PlayerRole?> activeRoleFilter = Rx<PlayerRole?>(null);
  final isEditing = false.obs;

  // Joined Contests State
  final joinedContestIds = <String>{}.obs;

  // Selected Team State (Stores Player IDs)
  final selectedPlayers = <String>[].obs;
  final rxCaptainId = ''.obs;
  final rxViceCaptainId = ''.obs;

  // Track team origin for max-7-per-team constraint
  String _team1Name = '';
  String _team2Name = '';
  String? _matchId;
  String? _lastLeaderboardContestId;

  // ── Computed getters ────────────────────────────────────────────

  List<PlayerInfo> get filteredPlayers {
    if (activeRoleFilter.value == null) {
      // Sort ALL players by role index: WK (0) -> BAT (1) -> AR (2) -> BOWL (3)
      final sorted = List<PlayerInfo>.from(allPlayerInfo);
      sorted.sort((a, b) => a.role.index.compareTo(b.role.index));
      return sorted;
    }
    return allPlayerInfo
        .where((p) => p.role == activeRoleFilter.value)
        .toList();
  }

  double get usedCredits => allPlayerInfo
      .where((p) => selectedPlayers.contains(p.id))
      .fold(0.0, (sum, p) => sum + p.credits);

  double get remainingCredits => PlayerUtils.maxCredits - usedCredits;

  int get team1SelectedCount => allPlayerInfo
      .where(
          (p) => p.teamName == _team1Name && selectedPlayers.contains(p.id))
      .length;

  int get team2SelectedCount => allPlayerInfo
      .where(
          (p) => p.teamName == _team2Name && selectedPlayers.contains(p.id))
      .length;

  Map<PlayerRole, int> get roleCounts {
    final counts = {
      PlayerRole.wk: 0,
      PlayerRole.bat: 0,
      PlayerRole.ar: 0,
      PlayerRole.bowl: 0,
    };
    for (final id in selectedPlayers) {
      final info = allPlayerInfo.firstWhereOrNull((p) => p.id == id);
      if (info != null) counts[info.role] = (counts[info.role] ?? 0) + 1;
    }
    return counts;
  }

  // ── Setup ────────────────────────────────────────────────────────

  void setupForMatch(MatchData matchData) {
    // Only reset state if switching to a DIFFERENT match
    final isNewMatch = _matchId == null || _matchId != matchData.id;
    
    _matchId = matchData.id;
    _team1Name = matchData.team1;
    _team2Name = matchData.team2;
    allPlayerInfo.value = PlayerUtils.buildPlayerInfoList(
      team1Players: matchData.team1PlayerData,
      team2Players: matchData.team2PlayerData,
      team1Name: matchData.team1,
      team2Name: matchData.team2,
    );
    
    if (isNewMatch) {
      // Clear state only for a fresh match entry
      selectedPlayers.clear();
      rxCaptainId.value = '';
      rxViceCaptainId.value = '';
      isEditing.value = false;
      joinedContestIds.clear();
      leaderboard.clear();
      
      if (_matchId != null) {
        loadSquadLocally(_matchId!);
      }
    }
  }

  // ── Remote data ─────────────────────────────────────────────────

  Future<void> fetchContests(String matchId) async {
    isLoading.value = true;
    try {
      final data = await repo.getContestsForMatch(matchId);
      contests.value = data;
      
      // Fetch user joined entries
      final userEntries = await repo.getUserEntries(matchId);
      joinedContestIds.clear();
      joinedContestIds.addAll(userEntries.map((e) => e['contestId'].toString()));
      
      // Restore squad from the first entry if available and local squad is empty
      if (userEntries.isNotEmpty && selectedPlayers.isEmpty) {
        final firstEntry = userEntries.first;
        
        final List<dynamic>? playersList = firstEntry['players'];
        if (playersList != null) {
          selectedPlayers.assignAll(playersList.map((p) => p.toString()).toList());
        }
        
        if (firstEntry['captainId'] != null) {
          rxCaptainId.value = firstEntry['captainId'].toString();
        }
        if (firstEntry['viceCaptainId'] != null) {
          rxViceCaptainId.value = firstEntry['viceCaptainId'].toString();
        }
      }
    } catch (e) {
      debugPrint('❌ Error in fetchContests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchLeaderboard(String contestId) async {
    final isNewContest = _lastLeaderboardContestId != contestId;
    _lastLeaderboardContestId = contestId;

    isLoading.value = true;
    if (isNewContest) {
      leaderboard.clear();
    }
    try {
      final data = await repo.getLeaderboard(contestId);
      leaderboard.value = data;
    } catch (e) {
      debugPrint('❌ Error in fetchLeaderboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Player selection ─────────────────────────────────────────────

  /// Returns a human-readable reason why the player cannot be added, or null.
  String? canAddPlayer(PlayerInfo info) {
    if (selectedPlayers.length >= PlayerUtils.totalPlayers) {
      return 'Team is full (11/11)';
    }

    // Team distribution check
    final fromThisTeam = info.teamName == _team1Name
        ? team1SelectedCount
        : team2SelectedCount;
    if (fromThisTeam >= PlayerUtils.maxFromOneTeam) {
      return 'Max ${PlayerUtils.maxFromOneTeam} players from one team';
    }

    return null;
  }

  void togglePlayer(PlayerInfo info) {
    if (selectedPlayers.contains(info.id)) {
      selectedPlayers.remove(info.id);
      if (rxCaptainId.value == info.id) rxCaptainId.value = '';
      if (rxViceCaptainId.value == info.id) rxViceCaptainId.value = '';
    } else {
      final reason = canAddPlayer(info);
      if (reason != null) {
        Get.snackbar('Cannot Add Player', reason,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
            borderRadius: 10);
        return;
      }
      selectedPlayers.add(info.id);
    }
    if (_matchId != null) saveSquadLocally(_matchId!);
  }

  /// Whether the squad is complete (11 players).
  bool get isTeamValid {
    return selectedPlayers.length == PlayerUtils.totalPlayers;
  }

  // ── Captain / Vice-Captain ────────────────────────────────────────

  void setCaptain(String playerId) {
    if (rxViceCaptainId.value == playerId) rxViceCaptainId.value = '';
    rxCaptainId.value =
        rxCaptainId.value == playerId ? '' : playerId;
    if (_matchId != null) saveSquadLocally(_matchId!);
  }

  void setViceCaptain(String playerId) {
    if (rxCaptainId.value == playerId) rxCaptainId.value = '';
    rxViceCaptainId.value =
        rxViceCaptainId.value == playerId ? '' : playerId;
    if (_matchId != null) saveSquadLocally(_matchId!);
  }

  // ── Join ─────────────────────────────────────────────────────────

  Future<bool> joinContest(String contestId) async {
    if (!isTeamValid) {
      Get.snackbar('Incomplete Team',
          'Please select exactly ${PlayerUtils.totalPlayers} players. Currently selected: ${selectedPlayers.length}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white);
      return false;
    }
    if (rxCaptainId.value.isEmpty || rxViceCaptainId.value.isEmpty) {
      AppSnackbars.showError('Please assign Captain and Vice Captain.');
      return false;
    }

    isJoining.value = true;
    final success = await repo.joinContest(
      contestId: contestId,
      userId: authStore.user.value?.id ?? '',
      players: selectedPlayers,
      captainId: rxCaptainId.value,
      viceCaptainId: rxViceCaptainId.value,
    );
    isJoining.value = false;

    if (success) {
      joinedContestIds.add(contestId);
      AppSnackbars.showSuccess('Successfully joined the contest.');
      return true;
    } else {
      AppSnackbars.showError('Failed to join contest. Please try again.');
      return false;
    }
  }

  void resetTeam() {
    selectedPlayers.clear();
    rxCaptainId.value = '';
    rxViceCaptainId.value = '';
    activeRoleFilter.value = null;
    if (_matchId != null) saveSquadLocally(_matchId!);
  }

  Future<void> saveSquadLocally(String matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'players': selectedPlayers.toList(),
        'captainId': rxCaptainId.value,
        'viceCaptainId': rxViceCaptainId.value,
      };
      await prefs.setString('squad_for_match_$matchId', jsonEncode(data));
      debugPrint('💾 Saved squad locally for match $matchId');
    } catch (e) {
      debugPrint('🚨 Error saving squad locally: $e');
    }
  }

  Future<void> loadSquadLocally(String matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('squad_for_match_$matchId');
      if (savedStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedStr);
        final List<dynamic>? playersList = decoded['players'];
        if (playersList != null && playersList.isNotEmpty) {
          selectedPlayers.assignAll(playersList.map((p) => p.toString()).toList());
        }
        rxCaptainId.value = decoded['captainId']?.toString() ?? '';
        rxViceCaptainId.value = decoded['viceCaptainId']?.toString() ?? '';
        debugPrint('💾 Loaded squad locally for match $matchId: ${selectedPlayers.length} players');
      }
    } catch (e) {
      debugPrint('🚨 Error loading squad locally: $e');
    }
  }
}
