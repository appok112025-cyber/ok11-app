import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/config/api_config.dart';
import 'package:ok11/app/utils/status_theme.dart';

class ContestRepository {
  // We use the same base URL as the main API Config for contests
  static String get _adminApiUrl => "${ApiConfig.baseUrl}${ApiConfig.apiPrefix}";

  bool get _isAuthenticated {
    if (!Get.isRegistered<AuthStore>()) return false;
    final authStore = Get.find<AuthStore>();
    return authStore.isAuthenticated.value && authStore.user.value != null;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Fetch contests for a match ─────────────────────────────────

  Future<List<ContestModel>> getContestsForMatch(String matchId) async {
    try {
      final url = Uri.parse('$_adminApiUrl/contests?matchId=$matchId');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dynamic raw = decoded['data'];
          // Handle both flat list and paginated { data: [...] } shapes
          final List<dynamic> items =
              raw is List ? raw : (raw['data'] as List<dynamic>? ?? []);
          return items.map((e) => ContestModel.fromJson(e)).toList();
        }
      }
      debugPrint('⚠️ getContestsForMatch non-200: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching contests for match: $e');
      return [];
    }
  }

  // ── Join a contest ─────────────────────────────────────────────

  Future<bool> joinContest({
    required String contestId,
    required String userId,
    required List<String> players,
    required String captainId,
    required String viceCaptainId,
  }) async {
    if (!_isAuthenticated) {
      Get.snackbar('Not signed in', 'Please log in to join a contest.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    try {
      final body = jsonEncode({
        'userId': userId,
        'players': players,
        'captainId': captainId,
        'viceCaptainId': viceCaptainId,
      });

      final url = Uri.parse('$_adminApiUrl/contests/$contestId/join');
      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true;
      }

      if (response.statusCode == 409) {
        Get.snackbar('Already Joined', 'You have already joined this contest.',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      debugPrint('⚠️ joinContest non-200: ${response.statusCode} — ${response.body}');
      return false;
    } catch (e) {
      debugPrint('❌ Error joining contest: $e');
      return false;
    }
  }

  // ── Get leaderboard ────────────────────────────────────────────

  Future<List<LeaderboardEntryModel>> getLeaderboard(String contestId) async {
    try {
      final url = Uri.parse('$_adminApiUrl/contests/$contestId/leaderboard');
      
      // Prevent client-side caching of the leaderboard
      final Map<String, String> requestHeaders = Map<String, String>.from(_headers);
      requestHeaders['Cache-Control'] = 'no-cache, no-store, must-revalidate';
      requestHeaders['Pragma'] = 'no-cache';
      requestHeaders['Expires'] = '0';

      final response = await http.get(url, headers: requestHeaders);
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dynamic raw = decoded['data'];
          final List<dynamic> items =
              raw is List ? raw : (raw['data'] as List<dynamic>? ?? []);
          return items.map((e) => LeaderboardEntryModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching leaderboard: $e');
      return [];
    }
  }

  // ── Get user's joined entries for a match ───────────────────────

  Future<List<Map<String, dynamic>>> getUserEntries(String matchId) async {
    if (!_isAuthenticated) return [];
    try {
      final authStore = Get.find<AuthStore>();
      final token = authStore.token.value;
      if (token == null) return [];

      final url = Uri.parse('$_adminApiUrl/contests/match/$matchId/me');
      final response = await http.get(url, headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> items = decoded['data'];
          // Return the full objects so we can extract player/squad data
          return items.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching user entries: $e');
      return [];
    }
  }
  Future<List<MyJoinedItem>> getAllJoinedMatches() async {
    if (!_isAuthenticated) return [];
    try {
      final authStore = Get.find<AuthStore>();
      final token = authStore.token.value;
      if (token == null) return [];

      final url = Uri.parse('$_adminApiUrl/contests/me/all');
      final response = await http.get(url, headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> entries = decoded['data'];
          final List<MyJoinedItem> items = [];

          for (var entry in entries) {
            final contestJson = entry['contestId'];
            if (contestJson == null) continue;
            
            final matchJson = contestJson['matchId'];
            if (matchJson == null) continue;

            // Extract points and rank from entry
            final double points = (entry['points'] ?? 0.0).toDouble();
            final int rank = entry['rank'] as int? ?? 0;

            final match = _parseMatchFromContestEntry(
              matchJson,
              score: points.toInt(),
              rank: rank,
            );
            if (match != null) {
              final contest = ContestModel.fromJson(contestJson);
              items.add(MyJoinedItem(
                match: match,
                contest: contest,
                points: points,
                rank: rank,
              ));
            }
          }
          return items;
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching all joined matches: $e');
      return [];
    }
  }

  MatchData? _parseMatchFromContestEntry(
    Map<String, dynamic> matchJson, {
    int score = 0,
    int? rank,
  }) {
    try {
      final teamA = matchJson['teamA'];
      final teamB = matchJson['teamB'];

      String team1 = '';
      String team2 = '';
      String? team1ImageUrl;
      String? team2ImageUrl;

      if (teamA is Map) {
        team1 = (teamA['name'] as String?) ?? '';
        team1ImageUrl = teamA['imageUrl'] as String?;
      } else if (teamA is String) {
        team1 = teamA;
      }

      if (teamB is Map) {
        team2 = (teamB['name'] as String?) ?? '';
        team2ImageUrl = teamB['imageUrl'] as String?;
      } else if (teamB is String) {
        team2 = teamB;
      }

      final statusStr = matchJson['status'] as String? ?? 'upcoming';
      MatchStatus status = MatchStatus.upcoming;
      try {
        status = MatchStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
          orElse: () => MatchStatus.upcoming,
        );
      } catch (e) {
        status = MatchStatus.upcoming;
      }

      final matchTimeStr = matchJson['matchTime'] as String?;
      String dateStr = 'TBD';
      String timeStr = 'TBD';
      if (matchTimeStr != null) {
        final matchTime = DateTime.parse(matchTimeStr).toLocal();
        dateStr = '${matchTime.day}/${matchTime.month}/${matchTime.year}';
        timeStr = '${matchTime.hour}:${matchTime.minute.toString().padLeft(2, '0')}';
      }

      return MatchData(
        id: matchJson['_id'] as String? ?? matchJson['id'] as String?,
        title: '$team1 VS $team2',
        team1: team1,
        team2: team2,
        team1ImageUrl: team1ImageUrl,
        team2ImageUrl: team2ImageUrl,
        date: dateStr,
        time: timeStr,
        score: score,
        rank: rank,
        status: status,
        participantsCount: matchJson['participantsCount'] as int?,
      );
    } catch (e) {
      return null;
    }
  }
}
