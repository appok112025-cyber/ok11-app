import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/widgets/common/save_proceed_button.dart';

class SquadView extends GetView<MatchDetailController> {
  const SquadView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('👥 SquadView.build()');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final match = controller.matchData.value;
          if (match == null) {
            return const Center(child: Text('No match data available'));
          }
          return _buildSquadContent(match);
        }),
      ),
    );
  }

  Widget _buildSquadContent(MatchData match) {
    return Column(
      children: [
        // Dream11-style progress header
        _buildProgressHeader(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildTeamColumn(
                  match.team1,
                  match.team1PlayerData,
                  match.team1ImageUrl,
                  'team1',
                ),
              ),
              Container(width: 1, color: Colors.grey.shade300),
              Expanded(
                child: _buildTeamColumn(
                  match.team2,
                  match.team2PlayerData,
                  match.team2ImageUrl,
                  'team2',
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final canSave = controller.isSquadComplete;
          debugPrint(
            '💾 SquadView: Can save=$canSave (total=${controller.totalSelectedPlayers}/${MatchDetailController.maxTotalPlayers})',
          );
          return SaveProceedButton(
            onTap: canSave
                ? () {
                    debugPrint('💾 SquadView: Save button tapped');
                    controller.saveSquad();
                  }
                : null,
          );
        }),
      ],
    );
  }

  /// Dream11-style progress indicator at the top
  Widget _buildProgressHeader() {
    return Obx(() {
      final total = controller.totalSelectedPlayers;
      final max = MatchDetailController.maxTotalPlayers;
      final progress = total / max;
      final isComplete = controller.isSquadComplete;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isComplete
                ? [
                    const Color(0xFF43A047),
                    const Color(0xFF66BB6A),
                  ]
                : [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isComplete ? Icons.check_circle : Icons.people_alt,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  isComplete
                      ? 'Squad Complete! ✓'
                      : 'Pick $max players from both teams',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white.withValues(alpha: 0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$total / $max players selected',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTeamColumn(
    String teamName,
    List<PlayerData> playerDataList,
    String? teamImageUrl,
    String teamId,
  ) {
    // Fall back to name list if playerData is empty
    final players =
        playerDataList.isNotEmpty
            ? playerDataList
            : controller.matchData.value
                    ?.let((match) {
                      final names =
                          teamId == 'team1'
                              ? match.team1Players
                              : match.team2Players;
                      return names
                          .map((n) => PlayerData(id: n, name: n))
                          .toList();
                    }) ??
                [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.primaryLighter, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (teamImageUrl != null && teamImageUrl.isNotEmpty)
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: teamImageUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(UniconsLine.bookmark,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                    placeholder: (context, url) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(UniconsLine.bookmark,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      teamName,
                      style: AppTextStyles.headline2.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final selectedCount = teamId == 'team1'
                          ? controller.selectedTeam1Players.length
                          : controller.selectedTeam2Players.length;
                      return Text(
                        '$selectedCount selected',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: players.isEmpty
              ? const Center(child: Text('No players'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final playerData = players[index];
                    return Obx(() {
                      final isSelected = controller.isPlayerSelected(
                        playerData.name,
                        teamId,
                      );
                      final isDisabled =
                          !isSelected && controller.isSquadComplete;

                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isDisabled ? 0.5 : 1.0,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: isSelected ? 1.5 : 0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: isDisabled
                                  ? null
                                  : () {
                                      debugPrint(
                                        '👤 SquadView: Toggling ${playerData.name} ($teamId)',
                                      );
                                      controller.togglePlayerSelection(
                                        playerData.name,
                                        teamId,
                                      );
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    // Player avatar with image
                                    _buildPlayerAvatar(
                                      playerData,
                                      isSelected,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        playerData.name,
                                        style: AppTextStyles.body1.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    // Selection indicator
                                    if (isSelected)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_circle,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
        ),
      ],
    );
  }

  /// Build player avatar — shows image if available, otherwise initial letter
  Widget _buildPlayerAvatar(PlayerData playerData, bool isSelected) {
    final hasImage =
        playerData.imageUrl != null && playerData.imageUrl!.isNotEmpty;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: playerData.imageUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(
                    playerData.name.isNotEmpty
                        ? playerData.name[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headline2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    playerData.name.isNotEmpty
                        ? playerData.name[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headline2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  playerData.name.isNotEmpty
                      ? playerData.name[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.headline2.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Extension to allow null-safe let operations like Kotlin
extension _LetExtension<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
