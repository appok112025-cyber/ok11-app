import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/modules/contest/views/leaderboard_view.dart';
import 'package:ok11/app/modules/contest/views/squad_preview_view.dart';

class CaptainSelectionView extends StatelessWidget {
  final ContestModel? contest;
  final MatchData matchData;

  const CaptainSelectionView(
      {Key? key, this.contest, required this.matchData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContestController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Captain & Vice Captain',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contest?.name ?? 'Choose your leaders',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildLegend(),
          _buildSelectedPlayerList(controller),
          _buildBottomBar(controller),
        ],
      ),
    );
  }


  Widget _buildLegend() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Captain chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('C',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    )),
                ),
                const SizedBox(width: 8),
                const Text(
                  '2x points',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Vice Captain chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('VC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    )),
                ),
                const SizedBox(width: 8),
                const Text(
                  '1.5x points',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSelectedPlayerList(ContestController controller) {
    return Expanded(
      child: Obx(() {
        final selected = controller.allPlayerInfo
            .where((p) => controller.selectedPlayers.contains(p.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: selected.length,
          itemBuilder: (context, index) {
            final info = selected[index];
            return Obx(() {
              final isCap = controller.rxCaptainId.value == info.id;
              final isVC = controller.rxViceCaptainId.value == info.id;
              return _CaptainCard(
                info: info,
                isCaptain: isCap,
                isViceCaptain: isVC,
                team1Name: matchData.team1,
                onCaptainTap: () => controller.setCaptain(info.id),
                onViceCaptainTap: () => controller.setViceCaptain(info.id),
              );
            });
          },
        );
      }),
    );
  }


  Widget _buildBottomBar(ContestController controller) {
    return Builder(
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: const Color(0xFFE5E7EB), width: 1.2)),
          ),
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding > 0 ? bottomPadding + 8 : 16),
          child: Obx(() {
            final capReady = controller.rxCaptainId.value.isNotEmpty;
            final vcReady = controller.rxViceCaptainId.value.isNotEmpty;
            final isReady = capReady && vcReady;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status row
                if (isReady)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('C',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('VC',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Both leaders assigned',
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Button
                ElevatedButton(
                  onPressed: controller.isJoining.value
                      ? null
                      : !isReady
                          ? null
                          : () async {
                              if (contest != null) {
                                final success = await controller.joinContest(contest!.id);
                                if (success) {
                                  controller.isEditing.value = false;
                                  Get.back(); // Pop CaptainSelectionView
                                  Get.to(() => LeaderboardView(contest: contest!, match: matchData));
                                }
                              } else {
                                controller.isEditing.value = false;
                                Get.back(); // Pop CaptainSelectionView
                                if (Get.isRegistered<MatchDetailController>()) {
                                  Get.find<MatchDetailController>().onTabChanged(1); // Go to Team tab
                                }
                                AppSnackbars.showSuccess(
                                  'Squad Saved! Confirm your squad or head to the contests tab to join.',
                                  context,
                                );
                              }
                            },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReady ? AppColors.primary : Colors.grey.shade200,
                    foregroundColor: isReady ? AppColors.accentGold : Colors.grey.shade400,
                    disabledForegroundColor: Colors.grey.shade400,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: isReady ? 2 : 0,
                  ),
                  child: controller.isJoining.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          isReady
                              ? (contest != null ? 'Save Team & Join Contest' : 'Save Squad')
                              : 'Pick Captain & Vice Captain',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isReady ? AppColors.accentGold : Colors.grey.shade500,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}


class _CaptainCard extends StatelessWidget {
  final PlayerInfo info;
  final bool isCaptain;
  final bool isViceCaptain;
  final String team1Name;
  final VoidCallback onCaptainTap;
  final VoidCallback onViceCaptainTap;

  const _CaptainCard({
    required this.info,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.team1Name,
    required this.onCaptainTap,
    required this.onViceCaptainTap,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCaptain
              ? AppColors.primary.withValues(alpha: 0.4)
              : isViceCaptain
                  ? AppColors.accentGold.withValues(alpha: 0.4)
                  : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            // Player Image with team badge
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ClipOval(
                    child: info.imageUrl != null && info.imageUrl!.isNotEmpty
                        ? Image.network(
                            info.imageUrl!,
                            width: 44,
                            height: 44,
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
                // Country/Team badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isTeam1 ? Colors.blue.shade700 : Colors.orange.shade700,
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
                  Text(info.name,
                      style: const TextStyle(
                          color: Color(0xFF0F1923),
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    '${info.roleLabel} • ${info.teamName}',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // C / VC toggle buttons
            Row(
              children: [
                _roleToggleBtn(
                  label: 'C',
                  isActive: isCaptain,
                  activeColor: AppColors.primary,
                  onTap: onCaptainTap,
                ),
                const SizedBox(width: 10),
                _roleToggleBtn(
                  label: 'VC',
                  isActive: isViceCaptain,
                  activeColor: AppColors.accentGold,
                  onTap: onViceCaptainTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleToggleBtn({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.w900,
            fontSize: label.length == 1 ? 15 : 11,
          ),
        ),
      ),
    );
  }
}
