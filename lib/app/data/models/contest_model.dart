import 'package:ok11/app/data/models/match_data.dart';

class PrizeRange {
  final int fromRank;
  final int toRank;
  final double prizeAmount;

  PrizeRange({
    required this.fromRank,
    required this.toRank,
    required this.prizeAmount,
  });

  factory PrizeRange.fromJson(Map<String, dynamic> json) {
    return PrizeRange(
      fromRank: json['fromRank'] ?? 0,
      toRank: json['toRank'] ?? 0,
      prizeAmount: (json['prizeAmount'] ?? 0).toDouble(),
    );
  }
}

class ContestModel {
  final String id;
  final String matchId;
  final String name;
  final double firstPrize;
  final double entryFee;
  final double originalEntryFee;
  final int totalParticipants;
  final int participantLimit;
  final String status;
  final bool isLocked;
  final List<PrizeRange>? prizeBreakdown;
  final String createdAt;

  ContestModel({
    required this.id,
    required this.matchId,
    required this.name,
    required this.firstPrize,
    required this.entryFee,
    this.originalEntryFee = 0.0,
    required this.totalParticipants,
    this.participantLimit = 100,
    required this.status,
    this.isLocked = false,
    this.prizeBreakdown,
    required this.createdAt,
  });

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    return ContestModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      matchId: json['matchId']?.toString() ?? '',
      name: json['name'] ?? '',
      firstPrize: (json['firstPrize'] ?? 0).toDouble(),
      entryFee: (json['entryFee'] ?? 0).toDouble(),
      originalEntryFee: (json['originalEntryFee'] ?? 0).toDouble(),
      totalParticipants: json['totalParticipants'] ?? 0,
      participantLimit: json['participantLimit'] ?? 100,
      status: json['status'] ?? 'Upcoming',
      isLocked: json['isLocked'] == true,
      prizeBreakdown: json['prizeBreakdown'] != null
          ? (json['prizeBreakdown'] as List)
              .map((x) => PrizeRange.fromJson(x))
              .toList()
          : null,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class LeaderboardEntryModel {
  final String userId;
  final String userName;
  final String? profileImage;
  final double points;
  final int rank;
  final bool paid;
  final List<String> players;
  final String? captainId;
  final String? viceCaptainId;

  LeaderboardEntryModel({
    required this.userId,
    required this.userName,
    this.profileImage,
    required this.points,
    required this.rank,
    required this.paid,
    required this.players,
    this.captainId,
    this.viceCaptainId,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    String uId = '';
    String uName = 'User';
    String? uImg;

    final user = json['userId'];
    if (user is Map) {
      uId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
      uName = user['displayName']?.toString() ?? user['name']?.toString() ?? user['email']?.toString() ?? 'User';
      uImg = user['photoURL']?.toString() ?? user['profileImage']?.toString();
    } else {
      uId = user?.toString() ?? '';
    }

    final playersList = <String>[];
    if (json['players'] is List) {
      for (final p in json['players']) {
        if (p is Map) {
          playersList.add(p['_id']?.toString() ?? p['id']?.toString() ?? '');
        } else if (p != null) {
          playersList.add(p.toString());
        }
      }
    }

    String? capId;
    if (json['captainId'] is Map) {
      capId = json['captainId']['_id']?.toString() ?? json['captainId']['id']?.toString();
    } else {
      capId = json['captainId']?.toString();
    }

    String? vcId;
    if (json['viceCaptainId'] is Map) {
      vcId = json['viceCaptainId']['_id']?.toString() ?? json['viceCaptainId']['id']?.toString();
    } else {
      vcId = json['viceCaptainId']?.toString();
    }

    return LeaderboardEntryModel(
      userId: uId,
      userName: uName,
      profileImage: uImg,
      points: (json['points'] ?? 0).toDouble(),
      rank: json['rank'] ?? 0,
      paid: json['paid'] ?? false,
      players: playersList,
      captainId: capId,
      viceCaptainId: vcId,
    );
  }
}

class MyJoinedItem {
  final MatchData match;
  final ContestModel? contest;
  final double? points;
  final int? rank;

  MyJoinedItem({
    required this.match,
    this.contest,
    this.points,
    this.rank,
  });
}
