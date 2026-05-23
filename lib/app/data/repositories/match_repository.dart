import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ok11/app/data/models/match_card_data.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/quiz_question.dart';
import 'package:ok11/app/data/models/team_data.dart';
import 'package:ok11/app/services/api_service.dart';
import 'package:ok11/app/utils/status_theme.dart';

class MatchRepository {
  final _apiService = Get.find<ApiService>();

  static List<MatchData> _inMemoryUpcoming = [];

  List<MatchData> getInMemoryUpcomingMatches() => _inMemoryUpcoming;

  Future<void> initCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_upcoming_matches');
      if (cachedStr != null) {
        final List<dynamic> decoded = jsonDecode(cachedStr);
        _inMemoryUpcoming = decoded
            .map((item) => MatchData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        debugPrint('💾 MatchRepository: Loaded ${_inMemoryUpcoming.length} matches from cache');
      }
    } catch (e) {
      debugPrint('🚨 MatchRepository.initCache error: $e');
    }
  }

  Future<void> cacheUpcomingMatches(List<MatchData> matchesList) async {
    _inMemoryUpcoming = matchesList;
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = matchesList.map((m) => m.toJson()).toList();
      await prefs.setString('cached_upcoming_matches', jsonEncode(serialized));
      debugPrint('💾 MatchRepository: Saved ${matchesList.length} matches to cache');
    } catch (e) {
      debugPrint('🚨 MatchRepository.cacheUpcomingMatches error: $e');
    }
  }

  TeamData? _parseTeam(Map<String, dynamic>? teamJson) {
    if (teamJson == null) return null;
    try {
      return TeamData.fromJson(teamJson);
    } catch (e) {
      return null;
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    final words = text.toLowerCase().split(' ');
    final titleCaseWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).toList();
    return titleCaseWords.join(' ');
  }

  String _getTeamName(dynamic team) {
    String name;
    if (team is Map) {
      final teamData = _parseTeam(Map<String, dynamic>.from(team));
      name = teamData?.name ?? '';
    } else {
      name = (team as String? ?? '').trim();
    }
    return _toTitleCase(name);
  }

  String? _getTeamImageUrl(dynamic team) {
    if (team is Map) {
      final teamData = _parseTeam(Map<String, dynamic>.from(team));
      return teamData?.imageUrl;
    }
    return null;
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    return '$day-$month-$year';
  }

  String _formatRelativeDate(DateTime matchTime, DateTime now) {
    final matchDate = DateTime(matchTime.year, matchTime.month, matchTime.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (matchDate == today) {
      return 'Today';
    } else if (matchDate == yesterday) {
      return 'Yesterday';
    } else if (matchDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return _formatDate(matchTime);
    }
  }

  String _formatTime(DateTime dateTime) {
    var hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'pm' : 'am';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }

  Future<List<MatchCardData>> getMatches() async {
    debugPrint('📥 MatchRepository.getMatches()');
    try {
      final response = await _apiService.get('/matches?page=1&limit=100');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          return [];
        }
        final dynamic jsonData = json['data'];
        List<dynamic>? matchesList;
        if (jsonData is List) {
          matchesList = jsonData;
        } else if (jsonData is Map) {
          matchesList = jsonData['data'] as List<dynamic>?;
        }

        if (matchesList == null || matchesList.isEmpty) {
          return [];
        }

        final now = DateTime.now();

        final matchesWithTime = matchesList.whereType<Map>().map((matchJson) {
          final match = Map<String, dynamic>.from(matchJson);
          final matchTimeStr = match['matchTime'] as String?;
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
            dateStr = _formatRelativeDate(matchTime, now);
            timeStr = _formatTime(matchTime);
          }

          final teamAJson = match['teamA'] ?? match['team1'];
          final teamBJson = match['teamB'] ?? match['team2'];

          final teamA = _getTeamName(teamAJson);
          final teamB = _getTeamName(teamBJson);
          final seriesName = teamA.isNotEmpty && teamB.isNotEmpty
              ? '$teamA VS $teamB'
              : 'Match';

          final teamAImageUrl =
              _getTeamImageUrl(teamAJson) ??
              match['teamAImageUrl'] as String? ??
              match['team1ImageUrl'] as String?;
          final teamBImageUrl =
              _getTeamImageUrl(teamBJson) ??
              match['teamBImageUrl'] as String? ??
              match['team2ImageUrl'] as String?;

          final participantsCount = match['participantsCount'] as int?;

          return {
            'matchCard': MatchCardData(
              seriesName: seriesName,
              team1: teamA,
              team2: teamB,
              team1ImageUrl: teamAImageUrl,
              team2ImageUrl: teamBImageUrl,
              date: dateStr,
              time: timeStr,
              participantsCount: participantsCount,
            ),
            'matchTime': matchTime ?? DateTime(0),
            'createdAt': match['createdAt'] != null
                ? DateTime.tryParse(match['createdAt'] as String) ?? DateTime(0)
                : DateTime(0),
          };
        }).toList();

        matchesWithTime.sort((a, b) {
          final aTime = a['matchTime'] as DateTime;
          final bTime = b['matchTime'] as DateTime;
          final aCreated = a['createdAt'] as DateTime;
          final bCreated = b['createdAt'] as DateTime;
          final timeCompare = bTime.compareTo(aTime);
          if (timeCompare != 0) return timeCompare;
          return bCreated.compareTo(aCreated);
        });

        final result = matchesWithTime
            .map((item) => item['matchCard'] as MatchCardData)
            .toList();
        debugPrint('✅ MatchRepository.getMatches: ${result.length} matches');
        return result;
      } else {
        debugPrint(
          '❌ MatchRepository.getMatches: Status ${response.statusCode}',
        );
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ MatchRepository.getMatches error: $e');
      throw Exception('Failed to load matches: $e');
    }
  }

  MatchStatus _parseStatus(String? status) {
    if (status == null) return MatchStatus.upcoming;
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'live':
        return MatchStatus.live;
      case 'completed':
        return MatchStatus.completed;
      case 'cancelled':
        return MatchStatus.cancelled;
      case 'upcoming':
      default:
        return MatchStatus.upcoming;
    }
  }

  Future<List<MatchData>> _fetchMatchesByStatus(String status) async {
    debugPrint('📥 MatchRepository._fetchMatchesByStatus: $status');
    try {
      final response = await _apiService.get(
        '/matches?status=$status&page=1&limit=100',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          return [];
        }
        final dynamic jsonData = json['data'];
        List<dynamic>? matchesList;
        if (jsonData is List) {
          matchesList = jsonData;
        } else if (jsonData is Map) {
          matchesList = jsonData['data'] as List<dynamic>?;
        }

        if (matchesList == null || matchesList.isEmpty) {
          return [];
        }

        final now = DateTime.now();

        final matchesWithTime = matchesList.whereType<Map>().map((matchJson) {
          final match = Map<String, dynamic>.from(matchJson);
          final matchTimeStr = match['matchTime'] as String?;
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
            dateStr = _formatRelativeDate(matchTime, now);
            timeStr = _formatTime(matchTime);
          }

          final teamAJson = match['teamA'] ?? match['team1'];
          final teamBJson = match['teamB'] ?? match['team2'];

          final teamA = _getTeamName(teamAJson);
          final teamB = _getTeamName(teamBJson);
          final matchName = match['matchName'] as String?;
          final title = (matchName != null && matchName.trim().isNotEmpty)
              ? matchName
              : (teamA.isNotEmpty && teamB.isNotEmpty
                    ? '$teamA VS $teamB'
                    : 'Match');
          final matchStatus = match['status'] as String? ?? 'Upcoming';
          final scoreStr = match['score'] as String?;
          int score = 0;
          if (scoreStr != null && scoreStr.isNotEmpty) {
            try {
              final parts = scoreStr.split('-');
              if (parts.isNotEmpty) {
                score = int.tryParse(parts[0].trim()) ?? 0;
              }
            } catch (e) {
              score = 0;
            }
          }

          final teamAImageUrl =
              _getTeamImageUrl(teamAJson) ??
              match['teamAImageUrl'] as String? ??
              match['team1ImageUrl'] as String?;
          final teamBImageUrl =
              _getTeamImageUrl(teamBJson) ??
              match['teamBImageUrl'] as String? ??
              match['team2ImageUrl'] as String?;
          final participantsCount = match['participantsCount'] as int?;

          final players = match['players'] as Map<String, dynamic>?;
          final team1PlayersList = <String>[];
          final team2PlayersList = <String>[];
          final team1PlayerDataList = <PlayerData>[];
          final team2PlayerDataList = <PlayerData>[];

          if (players != null) {
            final teamAPlayers = players['teamA'] as List<dynamic>? ?? [];
            final teamBPlayers = players['teamB'] as List<dynamic>? ?? [];

            for (var player in teamAPlayers) {
              final playerData = PlayerData.fromJson(player);
              team1PlayerDataList.add(playerData);
              team1PlayersList.add(playerData.name);
            }

            for (var player in teamBPlayers) {
              final playerData = PlayerData.fromJson(player);
              team2PlayerDataList.add(playerData);
              team2PlayersList.add(playerData.name);
            }
          }

          final quizzesData = match['quizzes'] as List<dynamic>? ?? [];
          final quizzesList = <QuizQuestion>[];
          debugPrint(
            '📝 MatchRepository: Parsing ${quizzesData.length} quizzes',
          );
          for (int i = 0; i < quizzesData.length; i++) {
            final quiz = quizzesData[i];
            if (quiz is Map) {
              final rawQuizId = quiz['quizId'] as String?;
              final rawId = quiz['_id'] as String?;
              final rawId2 = quiz['id'] as String?;
              final rawQuestionId = quiz['questionId'] as String?;
              final quizId = rawQuizId ?? rawId ?? rawId2 ?? rawQuestionId;

              debugPrint(
                '📝 MatchRepository: Quiz[$i] | quizId=$rawQuizId | _id=$rawId | id=$rawId2 | questionId=$rawQuestionId | final=$quizId',
              );

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

              if (question.isNotEmpty &&
                  options.length >= 2 &&
                  options.length <= 4) {
                quizzesList.add(
                  QuizQuestion(
                    quizId: quizId,
                    question: question,
                    options: options,
                  ),
                );
                debugPrint(
                  '✅ MatchRepository: Added quiz[$i] | quizId=$quizId | question="${question.substring(0, question.length > 30 ? 30 : question.length)}..." | options=${options.length}',
                );
              } else {
                debugPrint(
                  '⚠️ MatchRepository: Skipped quiz[$i] | questionEmpty=${question.isEmpty} | optionsCount=${options.length}',
                );
              }
            }
          }
          debugPrint(
            '✅ MatchRepository: Total quizzes parsed: ${quizzesList.length}',
          );

          final playerPointsMap = <String, double>{};
          final pointsJson = match['playerPoints'];
          if (pointsJson is Map) {
            pointsJson.forEach((key, value) {
              if (value is num) {
                playerPointsMap[key] = value.toDouble();
              }
            });
          }

          return {
            'matchData': MatchData(
              id: match['_id'] as String? ?? match['id'] as String?,
              title: title,
              matchName: match['matchName'] as String?,
              team1: teamA,
              team2: teamB,
              team1ImageUrl: teamAImageUrl,
              team2ImageUrl: teamBImageUrl,
              date: dateStr,
              time: timeStr,
              score: score,
              status: _parseStatus(matchStatus),
              participantsCount: participantsCount,
              team1Players: team1PlayersList,
              team2Players: team2PlayersList,
              team1PlayerData: team1PlayerDataList,
              team2PlayerData: team2PlayerDataList,
              quizzes: quizzesList,
              playerPoints: playerPointsMap,
            ),
            'matchTime': matchTime ?? DateTime(0),
            'createdAt': match['createdAt'] != null
                ? DateTime.tryParse(match['createdAt'] as String) ?? DateTime(0)
                : DateTime(0),
          };
        }).toList();

        matchesWithTime.sort((a, b) {
          final aTime = a['matchTime'] as DateTime;
          final bTime = b['matchTime'] as DateTime;
          final aCreated = a['createdAt'] as DateTime;
          final bCreated = b['createdAt'] as DateTime;
          final timeCompare = bTime.compareTo(aTime);
          if (timeCompare != 0) return timeCompare;
          return bCreated.compareTo(aCreated);
        });

        final result = matchesWithTime
            .map((item) => item['matchData'] as MatchData)
            .toList();
        debugPrint(
          '✅ MatchRepository._fetchMatchesByStatus: ${result.length} matches ($status)',
        );
        return result;
      } else {
        debugPrint(
          '❌ MatchRepository._fetchMatchesByStatus: Status ${response.statusCode}',
        );
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ MatchRepository._fetchMatchesByStatus error: $e');
      throw Exception('Failed to load matches: $e');
    }
  }

  Future<List<MatchData>> getUpcomingMatches() async {
    debugPrint('📥 MatchRepository.getUpcomingMatches()');
    return await _fetchMatchesByStatus('Upcoming');
  }

  Future<List<MatchData>> getLiveMatches() async {
    debugPrint('📥 MatchRepository.getLiveMatches()');
    return await _fetchMatchesByStatus('Live');
  }

  Future<List<MatchData>> getCompletedMatches() async {
    debugPrint('📥 MatchRepository.getCompletedMatches()');
    return await _fetchMatchesByStatus('Completed');
  }

  Future<List<MatchData>> getCancelledMatches() async {
    debugPrint('📥 MatchRepository.getCancelledMatches()');
    return await _fetchMatchesByStatus('Cancelled');
  }

  /// Fetches all matches and returns them organized by status
  /// Returns a map with keys: 'upcoming', 'live', 'past'
  Future<Map<String, List<MatchData>>> getAllMatchesGrouped() async {
    debugPrint('📥 MatchRepository.getAllMatchesGrouped()');
    try {
      // Fetch all statuses in parallel
      final results = await Future.wait([
        _fetchMatchesByStatus('Upcoming'),
        _fetchMatchesByStatus('Live'),
        _fetchMatchesByStatus('Completed'),
        _fetchMatchesByStatus('Cancelled'),
      ]);

      final upcoming = results[0];
      final live = results[1];
      final completed = results[2];
      final cancelled = results[3];

      // Combine completed and cancelled as "past" matches
      final past = [...completed, ...cancelled];

      debugPrint(
        '✅ MatchRepository.getAllMatchesGrouped: upcoming=${upcoming.length}, live=${live.length}, past=${past.length}',
      );

      return {'upcoming': upcoming, 'live': live, 'past': past};
    } catch (e) {
      debugPrint('❌ MatchRepository.getAllMatchesGrouped error: $e');
      throw Exception('Failed to load matches: $e');
    }
  }

  /// Fetches a single match by ID
  Future<MatchData?> getMatchById(String matchId) async {
    debugPrint('📥 MatchRepository.getMatchById: $matchId');
    try {
      final response = await _apiService.get('/matches/$matchId');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json == null) {
          return null;
        }
        final dynamic jsonData = json['data'];
        Map<String, dynamic>? match;
        if (jsonData is Map) {
          match = jsonData['match'] as Map<String, dynamic>? ?? Map<String, dynamic>.from(jsonData);
        }

        if (match == null) {
          return null;
        }

        final now = DateTime.now();
        final matchTimeStr = match['matchTime'] as String?;
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
          dateStr = _formatRelativeDate(matchTime, now);
          timeStr = _formatTime(matchTime);
        }

        final teamAJson = match['teamA'] ?? match['team1'];
        final teamBJson = match['teamB'] ?? match['team2'];

        final teamA = _getTeamName(teamAJson);
        final teamB = _getTeamName(teamBJson);
        final matchName = match['matchName'] as String?;
        final title = (matchName != null && matchName.trim().isNotEmpty)
            ? matchName
            : (teamA.isNotEmpty && teamB.isNotEmpty
                  ? '$teamA VS $teamB'
                  : 'Match');
        final matchStatus = match['status'] as String? ?? 'Upcoming';
        final scoreStr = match['score'] as String?;
        int score = 0;
        if (scoreStr != null && scoreStr.isNotEmpty) {
          try {
            final parts = scoreStr.split('-');
            if (parts.isNotEmpty) {
              score = int.tryParse(parts[0].trim()) ?? 0;
            }
          } catch (e) {
            score = 0;
          }
        }

        final teamAImageUrl =
            _getTeamImageUrl(teamAJson) ??
            match['teamAImageUrl'] as String? ??
            match['team1ImageUrl'] as String?;
        final teamBImageUrl =
            _getTeamImageUrl(teamBJson) ??
            match['teamBImageUrl'] as String? ??
            match['team2ImageUrl'] as String?;
        final participantsCount = match['participantsCount'] as int?;

        final players = match['players'] as Map<String, dynamic>?;
        final team1PlayersList = <String>[];
        final team2PlayersList = <String>[];
        final team1PlayerDataList = <PlayerData>[];
        final team2PlayerDataList = <PlayerData>[];

        if (players != null) {
          final teamAPlayers = players['teamA'] as List<dynamic>? ?? [];
          final teamBPlayers = players['teamB'] as List<dynamic>? ?? [];

          for (var player in teamAPlayers) {
            final playerData = PlayerData.fromJson(player);
            team1PlayerDataList.add(playerData);
            team1PlayersList.add(playerData.name);
          }

          for (var player in teamBPlayers) {
            final playerData = PlayerData.fromJson(player);
            team2PlayerDataList.add(playerData);
            team2PlayersList.add(playerData.name);
          }
        }

        final quizzesData = match['quizzes'] as List<dynamic>? ?? [];
        final quizzesList = <QuizQuestion>[];
        for (int i = 0; i < quizzesData.length; i++) {
          final quiz = quizzesData[i];
          if (quiz is Map) {
            final rawQuizId = quiz['quizId'] as String?;
            final rawId = quiz['_id'] as String?;
            final rawId2 = quiz['id'] as String?;
            final rawQuestionId = quiz['questionId'] as String?;
            final quizId = rawQuizId ?? rawId ?? rawId2 ?? rawQuestionId;

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

            if (question.isNotEmpty &&
                options.length >= 2 &&
                options.length <= 4) {
              quizzesList.add(
                QuizQuestion(
                  quizId: quizId,
                  question: question,
                  options: options,
                ),
              );
            }
          }
        }

        final playerPointsMap = <String, double>{};
        final pointsJson = match['playerPoints'];
        if (pointsJson is Map) {
          pointsJson.forEach((key, value) {
            if (value is num) {
              playerPointsMap[key] = value.toDouble();
            }
          });
        }

        final matchData = MatchData(
          id: match['_id'] as String? ?? match['id'] as String?,
          title: title,
          matchName: match['matchName'] as String?,
          team1: teamA,
          team2: teamB,
          team1ImageUrl: teamAImageUrl,
          team2ImageUrl: teamBImageUrl,
          date: dateStr,
          time: timeStr,
          score: score,
          status: _parseStatus(matchStatus),
          participantsCount: participantsCount,
          team1Players: team1PlayersList,
          team2Players: team2PlayersList,
          team1PlayerData: team1PlayerDataList,
          team2PlayerData: team2PlayerDataList,
          quizzes: quizzesList,
          playerPoints: playerPointsMap,
        );

        debugPrint(
          '✅ MatchRepository.getMatchById: Found match ${matchData.id} | status=${matchData.status}',
        );
        return matchData;
      } else {
        debugPrint(
          '❌ MatchRepository.getMatchById: Status ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ MatchRepository.getMatchById error: $e');
      return null;
    }
  }
}
