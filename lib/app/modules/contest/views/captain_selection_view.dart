import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/modules/contest/views/leaderboard_view.dart';

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
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(controller),
          _buildLegend(),
          _buildSelectedPlayerList(controller),
          _buildJoinButton(controller),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────

  Widget _buildHeader(ContestController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Get.back(),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign Captain & Vice Captain',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contest?.name ?? 'Choose your leaders',
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

  // ── Legend ───────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendBadge('C', const Color(0xFF1565C0), '2x points'),
          const SizedBox(width: 32),
          _legendBadge('VC', const Color(0xFFE65100), '1.5x points'),
        ],
      ),
    );
  }

  Widget _legendBadge(String label, Color color, String desc) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        const SizedBox(width: 8),
        Text(desc,
            style:
                TextStyle(color: const Color(0xFF0F1923), fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Selected player list ─────────────────────────────────────────

  Widget _buildSelectedPlayerList(ContestController controller) {
    return Expanded(
      child: Obx(() {
        // Build PlayerInfo list for selected players only
        final selected = controller.allPlayerInfo
            .where((p) => controller.selectedPlayers.contains(p.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
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

  // ── Join button ──────────────────────────────────────────────────

  Widget _buildJoinButton(ContestController controller) {
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
          final capReady = controller.rxCaptainId.value.isNotEmpty;
          final vcReady = controller.rxViceCaptainId.value.isNotEmpty;
          final isReady = capReady && vcReady;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small status row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statusDot('C', capReady),
                  const SizedBox(width: 24),
                  _statusDot('VC', vcReady),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.isJoining.value
                    ? null
                    : !isReady
                        ? null
                        : () async {
                            if (contest != null) {
                              final success =
                                  await controller.joinContest(contest!.id);
                              if (success) {
                                controller.isEditing.value = false;
                                Get.back(); // Pop CaptainSelectionView
                                Get.back(); // Pop TeamCreationView
                                Get.to(() => LeaderboardView(contest: contest!, match: matchData));
                              }
                            } else {
                              controller.isEditing.value = false;
                              Get.back();
                              if (Get.isRegistered<MatchDetailController>()) {
                                Get.find<MatchDetailController>().onTabChanged(0);
                              }
                              Get.snackbar('Squad Saved', 'Head over to the Contest tab to jump in!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                            }
                          },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady ? AppColors.primary : Colors.grey.shade200,
                  foregroundColor: Colors.white,
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isReady
                                ? (contest != null ? 'SAVE TEAM & JOIN CONTEST' : 'SAVE SQUAD')
                                : 'PICK CAPTAIN & VICE CAPTAIN',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ],
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _statusDot(String label, bool done) {
    return Row(
      children: [
        Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: done ? Colors.green : Colors.grey.shade300),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: done ? const Color(0xFF0F1923) : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: done ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

// ── Captain Card Widget ───────────────────────────────────────────

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCaptain
            ? Colors.blue.shade50
            : isViceCaptain
                ? Colors.orange.shade50
                : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCaptain
              ? Colors.blue.shade300
              : isViceCaptain
                  ? Colors.orange.shade300
                  : Colors.grey.shade200,
          width: isCaptain || isViceCaptain ? 1.5 : 1,
        ),
        boxShadow: [
          if (!isCaptain && !isViceCaptain)
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
            // Player Image
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
                  Text(info.name,
                      style: const TextStyle(
                          color: Color(0xFF0F1923),
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
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
            ),
            // C / VC toggle buttons
            Row(
              children: [
                _roleToggleBtn(
                  label: 'C',
                  isActive: isCaptain,
                  activeColor: const Color(0xFF1565C0),
                  onTap: onCaptainTap,
                ),
                const SizedBox(width: 12),
                _roleToggleBtn(
                  label: 'VC',
                  isActive: isViceCaptain,
                  activeColor: const Color(0xFFE65100),
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
            color: isActive ? activeColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w900,
            fontSize: label.length == 1 ? 14 : 11,
          ),
        ),
      ),
    );
  }
}
