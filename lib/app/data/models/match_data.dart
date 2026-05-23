import 'package:ok11/app/data/models/quiz_question.dart';
import 'package:ok11/app/utils/status_theme.dart';

class PlayerData {
  final String id;
  final String name;
  final String? imageUrl;
  final String? role;

  PlayerData({required this.id, required this.name, this.imageUrl, this.role});

  factory PlayerData.fromJson(dynamic json) {
    if (json is String) {
      return PlayerData(id: json, name: json);
    } else if (json is Map) {
      final id =
          json['_id'] as String? ?? json['id'] as String? ?? '';
      final name = json['name'] as String? ?? id;
      final role = json['role'] as String?;
      String? imageUrl = json['imageUrl'] as String? ?? 
                       json['image'] as String? ?? 
                       json['photoUrl'] as String? ?? 
                       json['photo'] as String?;
                       
      // If it's a relative path, prepend the base URL (from ApiConfig)
      if (imageUrl != null && imageUrl.startsWith('/')) {
        // We can't easily access ApiConfig here without importing it, 
        // but we can at least make it look like a valid URL if it's relative.
        // Actually, most images will be full URLs (CDN), but for local uploads:
        // imageUrl = 'http://10.0.2.2:5925$imageUrl'; 
        // For now, let's just make sure we don't break absolute URLs.
      }
      return PlayerData(id: id, name: name, imageUrl: imageUrl, role: role);
    }
    return PlayerData(id: json.toString(), name: json.toString());
  }
}

class MatchData {
  final String? id;
  final String title;
  final String? matchName;
  final String team1;
  final String team2;
  final String? team1ImageUrl;
  final String? team2ImageUrl;
  final String date;
  final String time;
  final int score;
  final int? rank;
  final MatchStatus status;
  final int? participantsCount;
  final List<String> team1Players;
  final List<String> team2Players;
  final List<PlayerData> team1PlayerData;
  final List<PlayerData> team2PlayerData;
  final List<QuizQuestion> quizzes;
  final Map<String, double> playerPoints;

  MatchData({
    this.id,
    required this.title,
    this.matchName,
    required this.team1,
    required this.team2,
    this.team1ImageUrl,
    this.team2ImageUrl,
    required this.date,
    required this.time,
    required this.score,
    this.rank,
    required this.status,
    this.participantsCount,
    this.team1Players = const [],
    this.team2Players = const [],
    this.team1PlayerData = const [],
    this.team2PlayerData = const [],
    this.quizzes = const [],
    this.playerPoints = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'matchName': matchName,
    'team1': team1,
    'team2': team2,
    'team1ImageUrl': team1ImageUrl,
    'team2ImageUrl': team2ImageUrl,
    'date': date,
    'time': time,
    'score': score,
    'rank': rank,
    'status': status.name,
    'participantsCount': participantsCount,
    'team1Players': team1Players,
    'team2Players': team2Players,
    'quizzes': quizzes
        .map((q) => {'question': q.question, 'options': q.options})
        .toList(),
  };

  factory MatchData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('MatchData is null');
    }
    final statusStr = json['status'] as String?;
    MatchStatus status = MatchStatus.upcoming;
    if (statusStr != null) {
      try {
        status = MatchStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
          orElse: () => MatchStatus.upcoming,
        );
      } catch (e) {
        status = MatchStatus.upcoming;
      }
    }
    final players = json['players'] as Map<String, dynamic>?;
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

    final quizzesList = <QuizQuestion>[];
    final quizzes = json['quizzes'] as List<dynamic>?;
    if (quizzes != null) {
      for (var quiz in quizzes) {
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
            final quizId =
                quiz['quizId'] as String? ??
                quiz['_id'] as String? ??
                quiz['id'] as String? ??
                quiz['questionId'] as String?;
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
    }

    final playerPointsMap = <String, double>{};
    final pointsJson = json['playerPoints'];
    if (pointsJson is Map) {
      pointsJson.forEach((key, value) {
        if (value is num) {
          playerPointsMap[key] = value.toDouble();
        }
      });
    }

    return MatchData(
      id: json['id'] as String? ?? json['_id'] as String?,
      title: (json['title'] as String?) ?? '',
      matchName: json['matchName'] as String?,
      team1: (json['team1'] as String?) ?? '',
      team2: (json['team2'] as String?) ?? '',
      team1ImageUrl: json['team1ImageUrl'] as String?,
      team2ImageUrl: json['team2ImageUrl'] as String?,
      date: (json['date'] as String?) ?? 'TBD',
      time: (json['time'] as String?) ?? 'TBD',
      score: (json['score'] as int?) ?? 0,
      rank: json['rank'] as int?,
      status: status,
      participantsCount: json['participantsCount'] as int?,
      team1Players: team1PlayersList,
      team2Players: team2PlayersList,
      team1PlayerData: team1PlayerDataList,
      team2PlayerData: team2PlayerDataList,
      quizzes: quizzesList,
      playerPoints: playerPointsMap,
    );
  }
}
