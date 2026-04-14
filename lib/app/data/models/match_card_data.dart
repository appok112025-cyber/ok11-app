class MatchCardData {
  final String seriesName;
  final String team1;
  final String team2;
  final String? team1ImageUrl;
  final String? team2ImageUrl;
  final String date;
  final String time;
  final int? participantsCount;

  MatchCardData({
    required this.seriesName,
    required this.team1,
    required this.team2,
    this.team1ImageUrl,
    this.team2ImageUrl,
    required this.date,
    required this.time,
    this.participantsCount,
  });

  String get teams => '$team1 VS $team2';

  Map<String, dynamic> toJson() => {
    'seriesName': seriesName,
    'team1': team1,
    'team2': team2,
    'team1ImageUrl': team1ImageUrl,
    'team2ImageUrl': team2ImageUrl,
    'date': date,
    'time': time,
    'participantsCount': participantsCount,
  };

  factory MatchCardData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('MatchCardData is null');
    }
    return MatchCardData(
      seriesName: (json['seriesName'] as String?) ?? '',
      team1: (json['team1'] as String?) ?? '',
      team2: (json['team2'] as String?) ?? '',
      team1ImageUrl: json['team1ImageUrl'] as String?,
      team2ImageUrl: json['team2ImageUrl'] as String?,
      date: (json['date'] as String?) ?? 'TBD',
      time: (json['time'] as String?) ?? 'TBD',
      participantsCount: json['participantsCount'] as int?,
    );
  }
}
