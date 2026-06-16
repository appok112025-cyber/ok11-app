import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/modules/contest/views/captain_selection_view.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';

class TeamCreationView extends StatelessWidget {
  final MatchData matchData;
  final ContestModel? contest;

  const TeamCreationView({Key? key, required this.matchData, this.contest})
    : super(key: key);

  static const _roleLabels = ['ALL', 'WK', 'BAT', 'AR', 'BOWL'];
  static const _roleValues = [
    null,
    PlayerRole.wk,
    PlayerRole.bat,
    PlayerRole.ar,
    PlayerRole.bowl,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContestController>();

    return Obx(() {
      // If the squad and captain are already picked, show the preview!
      if (controller.isTeamValid &&
          controller.rxCaptainId.isNotEmpty &&
          !controller.isEditing.value) {
        return _buildSquadPreview(context, controller);
      }

      // If selection is closed (match started/live/completed) and no squad is present
      if (matchData.status != MatchStatus.upcoming && !controller.isTeamValid) {
        return _buildClosedSelectionUI();
      }

      return Column(
        children: [
          _buildStatsBar(controller),
          _buildRoleTabBar(controller),
          _buildPlayerList(controller),
          _buildNextButton(controller),
        ],
      );
    });
  }

  Widget _buildSquadPreview(
    BuildContext context,
    ContestController controller,
  ) {
    final cap = controller.rxCaptainId.value;
    final vc = controller.rxViceCaptainId.value;

    // Map selected player IDs to PlayerInfo objects
    final players = controller.selectedPlayers
        .map((id) {
          return controller.allPlayerInfo.firstWhereOrNull((p) => p.id == id);
        })
        .whereType<PlayerInfo>()
        .toList();

    // Group players by role
    final wks = players.where((p) => p.role == PlayerRole.wk).toList();
    final bats = players.where((p) => p.role == PlayerRole.bat).toList();
    final ars = players.where((p) => p.role == PlayerRole.ar).toList();
    final bowls = players.where((p) => p.role == PlayerRole.bowl).toList();

    return Expanded(
      child: Column(
        children: [
          // Green Cricket Field Card
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                image: const DecorationImage(
                  image: AssetImage('assets/images/ground.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (wks.isNotEmpty) ...[
                    _buildRoleHeading('WICKET KEEPER'),
                    _buildPlayerRow(context, wks, cap, vc),
                  ],
                  if (bats.isNotEmpty) ...[
                    _buildRoleHeading('BATTERS'),
                    _buildPlayerRow(context, bats, cap, vc),
                  ],
                  if (ars.isNotEmpty) ...[
                    _buildRoleHeading('ALL ROUNDERS'),
                    _buildPlayerRow(context, ars, cap, vc),
                  ],
                  if (bowls.isNotEmpty) ...[
                    _buildRoleHeading('BOWLERS'),
                    _buildPlayerRow(context, bowls, cap, vc),
                  ],
                ],
              ),
            ),
          ),
          // Bottom Edit and Confirm buttons
          Builder(
            builder: (context) {
              final bottomPadding = MediaQuery.of(context).padding.bottom;
              final isUpcoming = matchData.status == MatchStatus.upcoming;

              return Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  bottomPadding > 0 ? bottomPadding + 8 : 16,
                ),
                child: Row(
                  children: [
                    if (isUpcoming) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Edit Team',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () {
                            controller.isEditing.value = true;
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'TOTAL POINTS:',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Builder(
                                builder: (ctx) {
                                  final totalPoints = players.fold<double>(
                                    0.0,
                                    (sum, p) {
                                      final basePoints =
                                          matchData.playerPoints[p.id] ?? 0.0;
                                      if (p.id == cap)
                                        return sum + basePoints * 2.0;
                                      if (p.id == vc)
                                        return sum + basePoints * 1.5;
                                      return sum + basePoints;
                                    },
                                  );
                                  return Text(
                                    totalPoints.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'TOTAL POINTS:',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Builder(
                                builder: (ctx) {
                                  final totalPoints = players.fold<double>(
                                    0.0,
                                    (sum, p) {
                                      final basePoints =
                                          matchData.playerPoints[p.id] ?? 0.0;
                                      if (p.id == cap)
                                        return sum + basePoints * 2.0;
                                      if (p.id == vc)
                                        return sum + basePoints * 1.5;
                                      return sum + basePoints;
                                    },
                                  );
                                  return Text(
                                    totalPoints.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleHeading(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    BuildContext context,
    List<PlayerInfo> players,
    String? cap,
    String? vc,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: players.map((p) {
        final isCap = cap == p.id;
        final isVc = vc == p.id;
        final pPoints = matchData.playerPoints[p.id] ?? 0.0;
        final isDt = matchData.status != MatchStatus.upcoming && pPoints >= 80;

        return _buildPreviewPlayerItem(context, p, isCap, isVc, isDt, pPoints);
      }).toList(),
    );
  }

  Widget _buildPreviewPlayerItem(
    BuildContext context,
    PlayerInfo pInfo,
    bool isCap,
    bool isVc,
    bool isDt,
    double pPoints,
  ) {
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
                          child: Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),
              ),
            ),

            // Captain / Vice Captain Indicator - Purple C, Gold VC
            if (isCap || isVc)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCap ? AppColors.primary : AppColors.accentGold,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
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

        // Player Name Pill
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

        // Live Points / Credit Cost Pill
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
            '${pPoints.toStringAsFixed(1)} Pts',
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

  Widget _buildHeader(BuildContext context, ContestController controller) {
    return Container(
      decoration: BoxDecoration(color: AppColors.primary),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Squad Selection',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
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

  Widget _buildStatsBar(ContestController controller) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Obx(() {
        final counts = controller.roleCounts;
        final selectedCount = controller.selectedPlayers.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top row: Team1 | SELECTED x/11 | Team2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Team 1 — name on top, count below
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        matchData.team1.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            '${controller.team1SelectedCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                            ),
                          )),
                    ],
                  ),

                  // Center: SELECTED x/11
                  Column(
                    children: [
                      const Text(
                        'SELECTED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$selectedCount',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5A20DF),
                              ),
                            ),
                            const TextSpan(
                              text: ' / 11',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Team 2 — name on top, count below
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        matchData.team2.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            '${controller.team2SelectedCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                            ),
                          )),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: selectedCount / 11.0,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF5A20DF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 8),

              // Role counts row (WK, BAT, AR, BOWL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoleStatItem('WK', counts[PlayerRole.wk] ?? 0),
                  _buildRoleStatItem('BAT', counts[PlayerRole.bat] ?? 0),
                  _buildRoleStatItem('AR', counts[PlayerRole.ar] ?? 0),
                  _buildRoleStatItem('BOWL', counts[PlayerRole.bowl] ?? 0),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRoleStatItem(String label, int count) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTabBar(ContestController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Obx(() {
        final active = controller.activeRoleFilter.value;
        final counts = controller.roleCounts;
        // Build labels with counts: ALL, WK (n), BAT (n), AR (n), BOWL (n)
        final labels = <String>['ALL'];
        final roles = [
          PlayerRole.wk,
          PlayerRole.bat,
          PlayerRole.ar,
          PlayerRole.bowl,
        ];
        final roleNames = ['WK', 'BAT', 'AR', 'BOWL'];
        for (int i = 0; i < roles.length; i++) {
          final c = counts[roles[i]] ?? 0;
          labels.add(c > 0 ? '${roleNames[i]} ($c)' : roleNames[i]);
        }

        return Row(
          children: List.generate(_roleLabels.length, (i) {
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
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade500,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
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

  Widget _buildPlayerList(ContestController controller) {
    return Expanded(
      child: Container(
        color: AppColors.background,
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
                final blocked =
                    !isSelected && controller.canAddPlayer(info) != null;
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

  Widget _buildNextButton(ContestController controller) {
    return Builder(
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            bottomPadding > 0 ? bottomPadding + 8 : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: const Color(0xFFE5E7EB), width: 1.2),
            ),
          ),
          child: Obx(() {
            final isValid = controller.isTeamValid;
            return ElevatedButton(
              onPressed: isValid
                  ? () => Get.to(
                      () => CaptainSelectionView(
                        contest: contest,
                        matchData: matchData,
                      ),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid
                    ? AppColors.primary
                    : Colors.grey.shade200,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade400,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isValid ? 2 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isValid
                        ? 'NEXT: ASSIGN CAPTAIN'
                        : 'SELECT ${PlayerUtils.totalPlayers - controller.selectedPlayers.length} MORE PLAYERS',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isValid) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildClosedSelectionUI() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

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
      case PlayerRole.wk:
        return const Color(0xFFE6B800);
      case PlayerRole.bat:
        return const Color(0xFF1565C0);
      case PlayerRole.ar:
        return const Color(0xFF2E7D32);
      case PlayerRole.bowl:
        return const Color(0xFFD84315);
      case PlayerRole.none:
        return Colors.grey;
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
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentGreen.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentGreen
                  : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                // Player Image with team flag badge
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            info.imageUrl != null && info.imageUrl!.isNotEmpty
                            ? Image.network(
                                info.imageUrl!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Text(
                                        info.roleLabel,
                                        style: TextStyle(
                                          color: _roleColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                              )
                            : Center(
                                child: Text(
                                  info.roleLabel,
                                  style: TextStyle(
                                    color: _roleColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Team badge overlay — circular
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isTeam1
                              ? Colors.blue.shade700
                              : Colors.orange.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          info.teamName.length > 2
                              ? info.teamName.substring(0, 2).toUpperCase()
                              : info.teamName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Name + role + team
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        style: const TextStyle(
                          color: Color(0xFF0F1923),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            info.roleLabel,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Add / Remove button - primary when not selected, green when selected
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentGreen : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentGreen
                          : AppColors.primary,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.add,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.primary,
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
