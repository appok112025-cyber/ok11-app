import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/modules/contest/views/captain_selection_view.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/utils/status_theme.dart';

class TeamCreationView extends StatelessWidget {
  final MatchData matchData;
  final ContestModel? contest;

  const TeamCreationView(
      {Key? key, required this.matchData, this.contest})
      : super(key: key);

  static const _roleLabels = ['ALL', 'WK', 'BAT', 'AR', 'BOWL'];
  static const _roleValues = [null, PlayerRole.wk, PlayerRole.bat, PlayerRole.ar, PlayerRole.bowl];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContestController>();

    return Obx(() {
      // If the squad and captain are already picked, show the preview!
      if (controller.isTeamValid && controller.rxCaptainId.isNotEmpty && !controller.isEditing.value) {
        return _buildSquadPreview(context, controller);
      }

      // If selection is closed (match started/live/completed) and no squad is present
      if (matchData.status != MatchStatus.upcoming && !controller.isTeamValid) {
        return _buildClosedSelectionUI();
      }

      return Column(
        children: [
          _buildHeader(context, controller),
          _buildStatsBar(controller),
          _buildRoleTabBar(controller),
          _buildPlayerList(controller),
          _buildNextButton(controller),
        ],
      );
    });
  }

  Widget _buildSquadPreview(BuildContext context, ContestController controller) {
    final cap = controller.rxCaptainId.value;
    final vc = controller.rxViceCaptainId.value;
    
    // Map selected player IDs to PlayerInfo objects
    final players = controller.selectedPlayers.map((id) {
      return controller.allPlayerInfo.firstWhereOrNull((p) => p.id == id);
    }).whereType<PlayerInfo>().toList();

    // Group players by role
    final wks = players.where((p) => p.role == PlayerRole.wk).toList();
    final bats = players.where((p) => p.role == PlayerRole.bat).toList();
    final ars = players.where((p) => p.role == PlayerRole.ar).toList();
    final bowls = players.where((p) => p.role == PlayerRole.bowl).toList();

    return Container(
      color: const Color(0xFF143F23), // Premium dark green stadium color
      child: Column(
        children: [
          // Header with edit button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0F301B), // Immersive dark green header
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Squad Preview', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (matchData.status == MatchStatus.upcoming)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    label: const Text('Edit Squad', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      controller.isEditing.value = true;
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                  ),
              ],
            ),
          ),
          
          // Immersive Grass Pitch Preview
          Expanded(
            child: Stack(
              children: [
                // 1. Cricket Field Ground Grass Background (Perfect Square in the Center)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.asset(
                        'assets/images/ground.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                // Subdued field overlay to make player names pop
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                ),

                // 2. Player Rows in custom 2-3-3-3 Grid
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _buildSquadGrid(context, controller, players),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadGrid(BuildContext context, ContestController controller, List<PlayerInfo> players) {
    final cap = controller.rxCaptainId.value;
    final vc = controller.rxViceCaptainId.value;

    final capInfo = players.firstWhereOrNull((p) => p.id == cap);
    final vcInfo = players.firstWhereOrNull((p) => p.id == vc);

    // Row 1: Captain & Vice-Captain
    final List<PlayerInfo> row1 = [];
    if (capInfo != null) row1.add(capInfo);
    if (vcInfo != null) row1.add(vcInfo);

    // Get all remaining players
    final allRemaining = players.where((p) => p.id != cap && p.id != vc).toList();
    
    // Fallback: If row1 doesn't have 2 players, pull from list
    while (row1.length < 2 && allRemaining.isNotEmpty) {
      row1.add(allRemaining.removeAt(0));
    }

    // Rows 2, 3, 4: Divide remaining 9 players into 3 rows of 3 players each
    final List<PlayerInfo> row2 = [];
    final List<PlayerInfo> row3 = [];
    final List<PlayerInfo> row4 = [];

    for (int i = 0; i < allRemaining.length; i++) {
      if (i < 3) {
        row2.add(allRemaining[i]);
      } else if (i < 6) {
        row3.add(allRemaining[i]);
      } else {
        row4.add(allRemaining[i]);
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildRowWrapper(context, cap, vc, row1),
        _buildRowWrapper(context, cap, vc, row2),
        _buildRowWrapper(context, cap, vc, row3),
        _buildRowWrapper(context, cap, vc, row4),
      ],
    );
  }

  Widget _buildRowWrapper(BuildContext context, String? cap, String? vc, List<PlayerInfo> list) {
    if (list.isEmpty) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list.map((p) {
        final isCap = cap == p.id;
        final isVc = vc == p.id;
        final pPoints = matchData.playerPoints[p.id] ?? 0.0;
        final isDt = matchData.status != MatchStatus.upcoming && pPoints >= 80;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildPreviewPlayerItem(context, p, isCap, isVc, isDt, pPoints),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewPlayerItem(BuildContext context, PlayerInfo pInfo, bool isCap, bool isVc, bool isDt, double pPoints) {
    final isTeam1 = pInfo.teamName == matchData.team1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Avatar Circle with team-colored border
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isTeam1 
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFFC2410C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: pInfo.imageUrl != null && pInfo.imageUrl!.isNotEmpty
                    ? Image.network(
                        pInfo.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Center(
                          child: Icon(Icons.person, color: Colors.white70, size: 28),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.person, color: Colors.white70, size: 28),
                      ),
              ),
            ),

            // Captain / Vice Captain Indicator
            if (isCap || isVc)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    isCap ? 'C' : 'VC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

            // Dream Team Gold Badge
            if (isDt)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    'DT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 6),

        // Player Name Pill (white box with bold text)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            pInfo.name,
            style: const TextStyle(
              color: Color(0xFF0F1923),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 4),

        // Live Points / Credit Cost Pill (Solid dark contrast container for 100% readability)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            matchData.status != MatchStatus.upcoming
                ? '${pPoints.toStringAsFixed(1)} Pts'
                : '${pInfo.credits} Cr',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ContestController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // Using app primary color for consistency
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${matchData.team1} vs ${matchData.team2}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Squad Selection',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats bar (X/11 | Team A | Team B | role counts) ────────────

  Widget _buildStatsBar(ContestController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        final counts = controller.roleCounts;
        return Column(
          children: [
            // Team distribution row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _teamPill(matchData.team1, controller.team1SelectedCount),
                _progressIndicator(controller.selectedPlayers.length),
                _teamPill(matchData.team2, controller.team2SelectedCount),
              ],
            ),
            const SizedBox(height: 12),
            // Role counts row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: PlayerRole.values
                  .where((r) => r != PlayerRole.none)
                  .map((role) {
                final constraints = PlayerUtils.roleConstraints[role]!;
                final current = counts[role] ?? 0;
                final min = constraints[0];
                final max = constraints[1];
                final isOk = current >= min;
                return _roleCountChip(
                  role.name,
                  current,
                  min,
                  max,
                  isOk,
                );
              }).toList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _teamPill(String teamName, int count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          '$teamName: $count',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Color(0xFF0F1923), fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _progressIndicator(int count) {
    return Column(
      children: [
        Text(
          '$count/11',
          style: const TextStyle(
              color: Color(0xFF0F1923), fontWeight: FontWeight.w900, fontSize: 18),
        ),
        Text('Players',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _roleCountChip(
      String label, int current, int min, int max, bool isOk) {
    return Column(
      children: [
        Text(
          '$current',
          style: TextStyle(
            color: isOk ? AppColors.accentGreen : Colors.grey.shade400,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── Role Tab Bar ─────────────────────────────────────────────────

  Widget _buildRoleTabBar(ContestController controller) {
    return Container(
      color: Colors.grey.shade50,
      child: Obx(() {
        final active = controller.activeRoleFilter.value;
        return Row(
          children: List.generate(_roleLabels.length, (i) {
            final label = _roleLabels[i];
            final role = _roleValues[i];
            final isActive = active == role;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.activeRoleFilter.value = role,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade600,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // ── Player List ──────────────────────────────────────────────────

  Widget _buildPlayerList(ContestController controller) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Obx(() {
          final players = controller.filteredPlayers;
          if (players.isEmpty) {
            return Center(
              child: Text(
                'No players in this category',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final info = players[index];
              return Obx(() {
                final isSelected = controller.selectedPlayers.contains(info.id);
                final blocked = !isSelected && controller.canAddPlayer(info) != null;
                return _PlayerCard(
                  info: info,
                  isSelected: isSelected,
                  isBlocked: blocked,
                  team1Name: matchData.team1,
                  onTap: () => controller.togglePlayer(info),
                );
              });
            },
          );
        }),
      ),
    );
  }

  // ── Next Button ──────────────────────────────────────────────────

  Widget _buildNextButton(ContestController controller) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() {
          final isValid = controller.isTeamValid;
          return ElevatedButton(
            onPressed: isValid
                ? () => Get.to(() => CaptainSelectionView(
                      contest: contest,
                      matchData: matchData,
                    ))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppColors.primary : Colors.grey.shade200,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey.shade400,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: isValid ? 2 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isValid ? 'NEXT: ASSIGN CAPTAIN' : 'SELECT ${PlayerUtils.totalPlayers - controller.selectedPlayers.length} MORE PLAYERS',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                if (isValid) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClosedSelectionUI() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_clock_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Squad Selection Closed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F1923),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'This match has already started or completed. You can no longer create or join squads for this match.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Player Card Widget ─────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final PlayerInfo info;
  final bool isSelected;
  final bool isBlocked;
  final String team1Name;
  final VoidCallback onTap;

  const _PlayerCard({
    required this.info,
    required this.isSelected,
    required this.isBlocked,
    required this.team1Name,
    required this.onTap,
  });

  Color get _roleColor {
    switch (info.role) {
      case PlayerRole.wk: return const Color(0xFFE6B800);
      case PlayerRole.bat: return const Color(0xFF1565C0);
      case PlayerRole.ar: return const Color(0xFF2E7D32);
      case PlayerRole.bowl: return const Color(0xFFD84315);
      case PlayerRole.none: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeam1 = info.teamName == team1Name;

    return Opacity(
      opacity: isBlocked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.shade50
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.green.shade300
                  : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Player Image / Role badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ClipOval(
                    child: info.imageUrl != null && info.imageUrl!.isNotEmpty
                        ? Image.network(
                            info.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(info.roleLabel,
                                style: TextStyle(
                                    color: _roleColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900)),
                            ),
                          )
                        : Center(
                            child: Text(info.roleLabel,
                              style: TextStyle(
                                  color: _roleColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900)),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name + team
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        style: const TextStyle(
                            color: Color(0xFF0F1923),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTeam1
                                  ? Colors.blue.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              info.teamName,
                              style: TextStyle(
                                  color: isTeam1
                                      ? Colors.blue.shade700
                                      : Colors.orange.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Add / Remove button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.shade500
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.green.shade500
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.add_rounded,
                    size: 20,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

