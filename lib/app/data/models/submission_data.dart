class SubmissionData {
  final String? id;
  final String? matchId;
  final String? selectedPlayer;
  final List<String>? teamASelectedPlayers;
  final List<String>? teamBSelectedPlayers;
  final List<PlayerData>? teamASelectedPlayerObjects;
  final List<PlayerData>? teamBSelectedPlayerObjects;
  final List<QuizAnswerData>? quizAnswers;
  final int? totalPoints;
  final int? totalPointsEarned;
  final String? status;
  final DateTime? submittedAt;
  final DateTime? evaluatedAt;
  final ScoreSummary? scoreSummary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubmissionData({
    this.id,
    this.matchId,
    this.selectedPlayer,
    this.teamASelectedPlayers,
    this.teamBSelectedPlayers,
    this.teamASelectedPlayerObjects,
    this.teamBSelectedPlayerObjects,
    this.quizAnswers,
    this.totalPoints,
    this.totalPointsEarned,
    this.status,
    this.submittedAt,
    this.evaluatedAt,
    this.scoreSummary,
    this.createdAt,
    this.updatedAt,
  });

  factory SubmissionData.fromJson(Map<String, dynamic> json) {
    final quizAnswersList = <QuizAnswerData>[];
    final quizAnswersJson = json['quizAnswers'] as List<dynamic>? ?? [];
    for (var answer in quizAnswersJson) {
      if (answer is Map<String, dynamic>) {
        quizAnswersList.add(QuizAnswerData.fromJson(answer));
      }
    }

    // Handle teamASelectedPlayers and teamBSelectedPlayers (new format)
    final teamASelectedPlayersList = <String>[];
    final teamBSelectedPlayersList = <String>[];
    final teamASelectedPlayerObjects = <PlayerData>[];
    final teamBSelectedPlayerObjects = <PlayerData>[];

    final teamAJson = json['teamASelectedPlayers'] as List<dynamic>?;
    if (teamAJson != null) {
      for (var player in teamAJson) {
        if (player is Map) {
          final playerId =
              player['_id'] as String? ??
              player['id'] as String? ??
              player.toString();
          teamASelectedPlayersList.add(playerId);
          // Also store player object if it has a name
          if (player['name'] != null) {
            teamASelectedPlayerObjects.add(
              PlayerData(
                id: playerId,
                name: player['name'] as String? ?? 'Unknown',
              ),
            );
          }
        } else if (player is String) {
          teamASelectedPlayersList.add(player);
        }
      }
    }

    final teamBJson = json['teamBSelectedPlayers'] as List<dynamic>?;
    if (teamBJson != null) {
      for (var player in teamBJson) {
        if (player is Map) {
          final playerId =
              player['_id'] as String? ??
              player['id'] as String? ??
              player.toString();
          teamBSelectedPlayersList.add(playerId);
          // Also store player object if it has a name
          if (player['name'] != null) {
            teamBSelectedPlayerObjects.add(
              PlayerData(
                id: playerId,
                name: player['name'] as String? ?? 'Unknown',
              ),
            );
          }
        } else if (player is String) {
          teamBSelectedPlayersList.add(player);
        }
      }
    }

    // Handle selectedPlayer (old format - for backward compatibility)
    String selectedPlayerValue = '';
    if (json['selectedPlayer'] != null) {
      if (json['selectedPlayer'] is Map) {
        selectedPlayerValue =
            (json['selectedPlayer']['name'] as String?) ??
            (json['selectedPlayer']['_id'] as String?) ??
            (json['selectedPlayer']['id'] as String?) ??
            '';
      } else {
        selectedPlayerValue = json['selectedPlayer'] as String? ?? '';
      }
    }

    final scoreSummaryJson = json['scoreSummary'] as Map<String, dynamic>?;
    final scoreSummary = scoreSummaryJson != null
        ? ScoreSummary(
            totalPointsAvailable:
                scoreSummaryJson['totalPointsAvailable'] as int?,
            totalPointsEarned: scoreSummaryJson['totalPointsEarned'] as int?,
            percentage: scoreSummaryJson['percentage'] as int?,
          )
        : null;

    return SubmissionData(
      id: json['_id'] as String? ?? json['id'] as String?,
      matchId: json['matchId'] is Map
          ? (json['matchId']['_id'] as String? ??
                json['matchId']['id'] as String?)
          : json['matchId'] as String?,
      selectedPlayer: selectedPlayerValue.isEmpty ? null : selectedPlayerValue,
      teamASelectedPlayers: teamASelectedPlayersList.isEmpty
          ? null
          : teamASelectedPlayersList,
      teamBSelectedPlayers: teamBSelectedPlayersList.isEmpty
          ? null
          : teamBSelectedPlayersList,
      teamASelectedPlayerObjects: teamASelectedPlayerObjects.isEmpty
          ? null
          : teamASelectedPlayerObjects,
      teamBSelectedPlayerObjects: teamBSelectedPlayerObjects.isEmpty
          ? null
          : teamBSelectedPlayerObjects,
      quizAnswers: quizAnswersList.isEmpty ? null : quizAnswersList,
      totalPoints: json['totalPoints'] as int?,
      totalPointsEarned: json['totalPointsEarned'] as int?,
      status: json['status'] as String?,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)?.toLocal()
          : null,
      evaluatedAt: json['evaluatedAt'] != null
          ? DateTime.tryParse(json['evaluatedAt'] as String)?.toLocal()
          : null,
      scoreSummary: scoreSummary,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)?.toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)?.toLocal()
          : null,
    );
  }
}

class PlayerData {
  final String id;
  final String name;

  PlayerData({required this.id, required this.name});
}

class ScoreSummary {
  final int? totalPointsAvailable;
  final int? totalPointsEarned;
  final int? percentage;

  ScoreSummary({
    this.totalPointsAvailable,
    this.totalPointsEarned,
    this.percentage,
  });
}

class QuizAnswerData {
  final String? quizId;
  final int? selectedOption;
  final bool? isCorrect;
  final int? pointsEarned;

  // Aggregated data (for completed matches)
  final String? question;
  final List<Map<String, dynamic>>? options;
  final int? userSelectedOption;
  final int? correctAnswer;
  final int? points;

  QuizAnswerData({
    this.quizId,
    this.selectedOption,
    this.isCorrect,
    this.pointsEarned,
    this.question,
    this.options,
    this.userSelectedOption,
    this.correctAnswer,
    this.points,
  });

  factory QuizAnswerData.fromJson(Map<String, dynamic> json) {
    final quizIdObj = json['quizId'];
    final quizId = quizIdObj is Map
        ? (quizIdObj['_id'] as String? ?? quizIdObj['id'] as String? ?? '')
        : quizIdObj as String? ?? '';

    // Check if this is aggregated data (for completed matches)
    final hasAggregatedData =
        json['question'] != null || json['options'] != null;

    // For aggregated data, userSelectedOption should be set from the JSON
    // For non-aggregated data, use selectedOption as fallback
    final userSelectedOpt = hasAggregatedData
        ? (json['userSelectedOption'] as int?)
        : (json['userSelectedOption'] as int? ??
              json['selectedOption'] as int?);

    return QuizAnswerData(
      quizId: quizId.isEmpty ? null : quizId,
      selectedOption: userSelectedOpt ?? json['selectedOption'] as int?,
      isCorrect: json['isCorrect'] as bool?,
      pointsEarned: json['pointsEarned'] as int?,
      question: hasAggregatedData ? json['question'] as String? : null,
      options: hasAggregatedData
          ? (json['options'] as List<dynamic>?)
                ?.map(
                  (opt) => opt is Map
                      ? Map<String, dynamic>.from(opt)
                      : {'text': opt.toString()},
                )
                .toList()
          : null,
      userSelectedOption: userSelectedOpt,
      correctAnswer: hasAggregatedData ? json['correctAnswer'] as int? : null,
      points: hasAggregatedData ? json['points'] as int? : null,
    );
  }

  bool get isAggregated => question != null;

  String getSelectedOptionText(List<String> questionOptions) {
    if (isAggregated && options != null) {
      final selectedIndex = userSelectedOption ?? selectedOption;
      if (selectedIndex != null &&
          selectedIndex >= 0 &&
          selectedIndex < options!.length) {
        return options![selectedIndex]['text']?.toString() ?? 'N/A';
      }
    } else {
      final selectedIndex = selectedOption;
      if (selectedIndex != null &&
          selectedIndex >= 0 &&
          selectedIndex < questionOptions.length) {
        return questionOptions[selectedIndex];
      }
    }
    return 'N/A';
  }
}
