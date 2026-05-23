// Deterministic utility to assign realistic roles and credits to players
import 'package:ok11/app/data/models/match_data.dart';
// when the backend does not provide this data.
//
// Roles: wk (Wicket Keeper), bat (Batsman), ar (All-Rounder), bowl (Bowler)
// Credits: 7.0 – 10.5 (in 0.5 increments)

enum PlayerRole { wk, bat, ar, bowl, none }

class PlayerInfo {
  final String id;
  final String name;
  final String? imageUrl;
  final String teamName;
  final PlayerRole role;
  final double credits;

  const PlayerInfo({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.teamName,
    required this.role,
    required this.credits,
  });

  String get roleLabel {
    switch (role) {
      case PlayerRole.wk:
        return 'WK';
      case PlayerRole.bat:
        return 'BAT';
      case PlayerRole.ar:
        return 'AR';
      case PlayerRole.bowl:
        return 'BOWL';
      case PlayerRole.none:
        return '---';
    }
  }
}

class PlayerUtils {
  /// Simple deterministic hash from a player name to spread roles evenly.
  static int _hash(String name) {
    int h = 0;
    for (int i = 0; i < name.length; i++) {
      h = (31 * h + name.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return h;
  }

  /// Assigns a role based on the player's position in the team list.
  /// Standard cricket squad distribution:
  ///   Index 0        → WK
  ///   Index 1-3      → BAT
  ///   Index 4-5      → AR
  ///   Index 6-10     → BOWL
  /// If there are fewer/more players, we fall back to hash-based assignment.
  static PlayerRole _roleFromIndex(int index, int totalPlayers) {
    if (totalPlayers >= 11) {
      if (index == 0) return PlayerRole.wk;
      if (index <= 3) return PlayerRole.bat;
      if (index <= 5) return PlayerRole.ar;
      return PlayerRole.bowl;
    }
    // Fallback: distribute using modulo
    switch (index % 4) {
      case 0:
        return PlayerRole.wk;
      case 1:
        return PlayerRole.bat;
      case 2:
        return PlayerRole.ar;
      default:
        return PlayerRole.bowl;
    }
  }

  /// Generates a credit value (7.0 – 10.5 in 0.5 steps) deterministically.
  static double _creditFromHash(int hash) {
    // 8 possible values: 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5
    final bucket = hash % 8;
    return 7.0 + bucket * 0.5;
  }

  /// Build a full list of [PlayerInfo] from the raw PlayerData lists.
  static List<PlayerInfo> buildPlayerInfoList({
    required List<PlayerData> team1Players,
    required List<PlayerData> team2Players,
    required String team1Name,
    required String team2Name,
  }) {
    final List<PlayerInfo> result = [];

    for (int i = 0; i < team1Players.length; i++) {
      final player = team1Players[i];
      
      // Use the real role if available, otherwise 'none'
      PlayerRole role = PlayerRole.none;
      if (player.role != null && player.role!.isNotEmpty) {
        role = PlayerRole.values.firstWhere(
          (e) => e.name == player.role!.toLowerCase(),
          orElse: () => PlayerRole.none,
        );
      }
      
      final credits = _creditFromHash(_hash(player.name));
      result.add(PlayerInfo(
        id: player.id,
        name: player.name,
        imageUrl: player.imageUrl,
        teamName: team1Name,
        role: role,
        credits: credits,
      ));
    }

    for (int i = 0; i < team2Players.length; i++) {
      final player = team2Players[i];
      
      // Use the real role if available, otherwise 'none'
      PlayerRole role = PlayerRole.none;
      if (player.role != null && player.role!.isNotEmpty) {
        role = PlayerRole.values.firstWhere(
          (e) => e.name == player.role!.toLowerCase(),
          orElse: () => PlayerRole.none,
        );
      }
      
      final credits = _creditFromHash(_hash(player.name));
      result.add(PlayerInfo(
        id: player.id,
        name: player.name,
        imageUrl: player.imageUrl,
        teamName: team2Name,
        role: role,
        credits: credits,
      ));
    }

    return result;
  }

  /// Role constraints for Dream11-style selection.
  static const Map<PlayerRole, List<int>> roleConstraints = {
    PlayerRole.wk:   [1, 4],
    PlayerRole.bat:  [3, 6],
    PlayerRole.ar:   [1, 4],
    PlayerRole.bowl: [3, 6],
  };

  static const double maxCredits = 100.0;
  static const int maxFromOneTeam = 7;
  static const int totalPlayers = 11;
}
