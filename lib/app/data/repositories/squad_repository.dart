import 'package:flutter/foundation.dart';

class SquadRepository {
  Future<List<String>> getEnglandPlayers() async {
    debugPrint('📥 SquadRepository.getEnglandPlayers()');
    await Future.delayed(const Duration(milliseconds: 100));
    final result = [
      'Zak Crawley',
      'Ben Duckett',
      'Ollie Pope',
      'Joe Root',
      'Harry Brook',
      'Ben Stokes',
      'Jamie Smith',
      'Chris Woakes',
      'Brydon Carse',
      'Jofra Archer',
      'Shoaib Bashir',
    ];
    debugPrint('✅ SquadRepository.getEnglandPlayers: ${result.length} players');
    return result;
  }

  Future<List<String>> getIndiaPlayers() async {
    debugPrint('📥 SquadRepository.getIndiaPlayers()');
    await Future.delayed(const Duration(milliseconds: 100));
    final result = [
      'Yashasvi Jaiswal',
      'KL Rahul',
      'Karun Nair',
      'Shubman Gill',
      'Rishabh Pant',
      'NK Reddy',
      'Ravindra Jadeja',
      'Washi Sundar',
      'Bumrah',
      'Motta Siraj',
      'Akash Deep',
    ];
    debugPrint('✅ SquadRepository.getIndiaPlayers: ${result.length} players');
    return result;
  }

  Future<List<String>> getPlayersByTeamName(String teamName) async {
    debugPrint('📥 SquadRepository.getPlayersByTeamName: $teamName');
    await Future.delayed(const Duration(milliseconds: 100));
    final normalizedName = teamName.toLowerCase().trim();

    if (normalizedName.contains('england')) {
      return await getEnglandPlayers();
    } else if (normalizedName.contains('india')) {
      return await getIndiaPlayers();
    } else {
      debugPrint('⚠️ SquadRepository.getPlayersByTeamName: Unknown team');
      return [];
    }
  }

  Future<bool> saveSquad(List<String> selectedPlayers) async {
    debugPrint(
      '💾 SquadRepository.saveSquad: ${selectedPlayers.length} players',
    );
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('✅ SquadRepository.saveSquad: Success');
    return true;
  }
}
