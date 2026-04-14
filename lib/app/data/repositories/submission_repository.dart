import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/quiz_question.dart';
import 'package:ok11/app/data/models/submission_data.dart';
import 'package:ok11/app/services/api_service.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/utils/status_theme.dart';

class SubmissionRepository {
  final _apiService = Get.find<ApiService>();

  /// Check if user is authenticated before making API calls
  bool get _isAuthenticated {
    if (!Get.isRegistered<AuthStore>()) return false;
    final authStore = Get.find<AuthStore>();
    return authStore.isAuthenticated.value && authStore.user.value != null;
  }

  Future<Set<String>> getUserSubmittedMatchIds() async {
    if (!_isAuthenticated) {
      debugPrint(
        '⚠️ SubmissionRepository.getUserSubmittedMatchIds: Skipped - user not authenticated',
      );
      return {};
    }

    debugPrint('📥 SubmissionRepository.getUserSubmittedMatchIds()');
    try {
      final response = await _apiService.get(
        '/submissions/me?page=1&limit=100',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          return {};
        }

        final data = json['data'] as Map<String, dynamic>?;
        final submissionsList = data?['data'] as List<dynamic>?;

        if (submissionsList == null || submissionsList.isEmpty) {
          return {};
        }

        final matchIds = <String>{};

        for (var submission in submissionsList) {
          if (submission is Map<String, dynamic>) {
            final matchIdObj = submission['matchId'];
            String? matchId;

            if (matchIdObj is Map) {
              matchId =
                  matchIdObj['_id'] as String? ?? matchIdObj['id'] as String?;
            } else if (matchIdObj is String) {
              matchId = matchIdObj;
            }

            if (matchId != null && matchId.isNotEmpty) {
              matchIds.add(matchId);
            }
          }
        }

        debugPrint(
          '✅ SubmissionRepository.getUserSubmittedMatchIds: ${matchIds.length} match IDs',
        );
        return matchIds;
      } else {
        debugPrint(
          '❌ SubmissionRepository.getUserSubmittedMatchIds: Status ${response.statusCode}',
        );
        return {};
      }
    } catch (e) {
      debugPrint('❌ SubmissionRepository.getUserSubmittedMatchIds error: $e');
      return {};
    }
  }

  Future<List<MatchData>> getUserSubmissions() async {
    if (!_isAuthenticated) {
      debugPrint(
        '⚠️ SubmissionRepository.getUserSubmissions: Skipped - user not authenticated',
      );
      return [];
    }

    debugPrint('📥 SubmissionRepository.getUserSubmissions()');
    try {
      final response = await _apiService.get(
        '/submissions/me?page=1&limit=100',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          return [];
        }

        final data = json['data'] as Map<String, dynamic>?;
        final submissionsList = data?['data'] as List<dynamic>?;

        if (submissionsList == null || submissionsList.isEmpty) {
          return [];
        }

        final matches = <MatchData>[];

        for (var submission in submissionsList) {
          if (submission is Map<String, dynamic>) {
            final matchData = submission['matchId'] as Map<String, dynamic>?;
            if (matchData != null) {
              final match = _parseMatchFromSubmission(matchData, submission);
              if (match != null) {
                matches.add(match);
              }
            }
          }
        }

        debugPrint(
          '✅ SubmissionRepository.getUserSubmissions: ${matches.length} matches',
        );
        return matches;
      } else {
        debugPrint(
          '❌ SubmissionRepository.getUserSubmissions: Status ${response.statusCode}',
        );
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ SubmissionRepository.getUserSubmissions error: $e');
      throw Exception('Failed to load submissions: $e');
    }
  }

  MatchData? _parseMatchFromSubmission(
    Map<String, dynamic> matchJson,
    Map<String, dynamic> submissionJson,
  ) {
    try {
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

      final teamA = matchJson['teamA'] ?? matchJson['team1'];
      final teamB = matchJson['teamB'] ?? matchJson['team2'];

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

      final title = team1.isNotEmpty && team2.isNotEmpty
          ? '$team1 VS $team2'
          : 'Match';

      final matchTimeStr = matchJson['matchTime'] as String?;
      DateTime? matchTime;
      if (matchTimeStr != null) {
        try {
          matchTime = DateTime.parse(matchTimeStr).toLocal();
        } catch (e) {
          matchTime = null;
        }
      }

      String dateStr = 'TBD';
      String timeStr = 'TBD';
      if (matchTime != null) {
        final now = DateTime.now();
        final matchDate = DateTime(
          matchTime.year,
          matchTime.month,
          matchTime.day,
        );
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final tomorrow = today.add(const Duration(days: 1));

        if (matchDate == today) {
          dateStr = 'Today';
        } else if (matchDate == yesterday) {
          dateStr = 'Yesterday';
        } else if (matchDate == tomorrow) {
          dateStr = 'Tomorrow';
        } else {
          final day = matchTime.day.toString().padLeft(2, '0');
          final month = matchTime.month.toString().padLeft(2, '0');
          final year = matchTime.year.toString().substring(2);
          dateStr = '$day-$month-$year';
        }

        var hour = matchTime.hour;
        final minute = matchTime.minute;
        final period = hour >= 12 ? 'pm' : 'am';
        if (hour > 12) {
          hour -= 12;
        } else if (hour == 0) {
          hour = 12;
        }
        final minuteStr = minute.toString().padLeft(2, '0');
        timeStr = '$hour:$minuteStr $period';
      }

      final totalPointsEarned =
          submissionJson['totalPointsEarned'] as int? ?? 0;
      final score = totalPointsEarned;

      final players = matchJson['players'] as Map<String, dynamic>?;
      final team1PlayersList = <String>[];
      final team2PlayersList = <String>[];

      if (players != null) {
        final teamAPlayers = players['teamA'] as List<dynamic>? ?? [];
        final teamBPlayers = players['teamB'] as List<dynamic>? ?? [];

        for (var player in teamAPlayers) {
          if (player is String) {
            team1PlayersList.add(player);
          } else if (player is Map) {
            final name = player['name'] as String?;
            if (name != null) team1PlayersList.add(name);
          }
        }

        for (var player in teamBPlayers) {
          if (player is String) {
            team2PlayersList.add(player);
          } else if (player is Map) {
            final name = player['name'] as String?;
            if (name != null) team2PlayersList.add(name);
          }
        }
      }

      final quizzesData = matchJson['quizzes'] as List<dynamic>? ?? [];
      final quizzesList = <QuizQuestion>[];
      for (var quiz in quizzesData) {
        if (quiz is Map) {
          final question = quiz['question'] as String? ?? '';
          final optionsData = quiz['options'] as List<dynamic>? ?? [];
          final options = <String>[];

          for (var opt in optionsData) {
            if (opt is String) {
              options.add(opt);
            } else if (opt is Map) {
              final text = opt['text'] as String?;
              if (text != null) options.add(text);
            }
          }

          if (question.isNotEmpty && options.isNotEmpty) {
            quizzesList.add(QuizQuestion(question: question, options: options));
          }
        }
      }

      return MatchData(
        id: matchJson['_id'] as String? ?? matchJson['id'] as String?,
        title: title,
        team1: team1,
        team2: team2,
        team1ImageUrl: team1ImageUrl,
        team2ImageUrl: team2ImageUrl,
        date: dateStr,
        time: timeStr,
        score: score,
        status: status,
        participantsCount: matchJson['participantsCount'] as int?,
        team1Players: team1PlayersList,
        team2Players: team2PlayersList,
        quizzes: quizzesList,
      );
    } catch (e) {
      return null;
    }
  }

  Future<SubmissionData?> getUserSubmissionForMatch(String matchId) async {
    if (!_isAuthenticated) {
      debugPrint(
        '⚠️ SubmissionRepository.getUserSubmissionForMatch: Skipped - user not authenticated',
      );
      return null;
    }

    debugPrint('📥 SubmissionRepository.getUserSubmissionForMatch: $matchId');
    try {
      final response = await _apiService.get(
        '/submissions/user/match/$matchId',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          return null;
        }

        final data = json['data'];
        if (data == null) {
          return null;
        }

        final submissionJson = data is Map
            ? Map<String, dynamic>.from(data)
            : null;
        if (submissionJson == null) {
          return null;
        }

        final result = SubmissionData.fromJson(submissionJson);
        debugPrint(
          '✅ SubmissionRepository.getUserSubmissionForMatch: Found (id=${result.id})',
        );
        return result;
      } else {
        debugPrint(
          'ℹ️ SubmissionRepository.getUserSubmissionForMatch: Not found (status=${response.statusCode})',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ SubmissionRepository.getUserSubmissionForMatch error: $e');
      return null;
    }
  }

  Future<SubmissionData?> createOrUpdateSubmission({
    required String userId,
    required String matchId,
    required List<String> teamASelectedPlayers,
    required List<String> teamBSelectedPlayers,
    required List<Map<String, dynamic>> quizAnswers,
  }) async {
    if (!_isAuthenticated) {
      debugPrint(
        '⚠️ SubmissionRepository.createOrUpdateSubmission: Skipped - user not authenticated',
      );
      throw Exception('User not authenticated');
    }

    debugPrint(
      '💾 SubmissionRepository.createOrUpdateSubmission: userId=$userId, matchId=$matchId, teamA=${teamASelectedPlayers.length}, teamB=${teamBSelectedPlayers.length}, answers=${quizAnswers.length}',
    );
    try {
      final requestBody = {
        'userId': userId,
        'matchId': matchId,
        'teamASelectedPlayers': teamASelectedPlayers,
        'teamBSelectedPlayers': teamBSelectedPlayers,
        'quizAnswers': quizAnswers,
      };

      // Try update first (most common case), fallback to create
      try {
        final existing = await getUserSubmissionForMatch(matchId);
        if (existing != null) {
          debugPrint(
            '🔄 SubmissionRepository.createOrUpdateSubmission: Updating existing (id=${existing.id})',
          );
          final response = await _apiService
              .put('/submissions/${existing.id}', {
                'teamASelectedPlayers': teamASelectedPlayers,
                'teamBSelectedPlayers': teamBSelectedPlayers,
                'quizAnswers': quizAnswers,
              });

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            final json = decoded is Map
                ? Map<String, dynamic>.from(decoded)
                : null;
            if (json != null) {
              final data = json['data'] as Map<String, dynamic>?;
              if (data != null) {
                debugPrint(
                  '✅ SubmissionRepository.createOrUpdateSubmission: Updated successfully',
                );
                return SubmissionData.fromJson(data);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Update failed, trying create: $e');
      }

      debugPrint(
        '➕ SubmissionRepository.createOrUpdateSubmission: Creating new',
      );
      final response = await _apiService.post('/submissions', requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            debugPrint(
              '✅ SubmissionRepository.createOrUpdateSubmission: Created successfully',
            );
            return SubmissionData.fromJson(data);
          }
        }
      }
      debugPrint('❌ SubmissionRepository.createOrUpdateSubmission: Failed');
      return null;
    } catch (e) {
      debugPrint('❌ SubmissionRepository.createOrUpdateSubmission error: $e');
      rethrow;
    }
  }
}
