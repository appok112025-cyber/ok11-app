import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.primary.withValues(alpha: 0.05),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select 11 players from both team',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildTeamColumn(
                  match.team1,
                  match.team1Players,
                  match.team1ImageUrl,
                  'team1',
                ),
              ),
              Container(width: 1, color: Colors.grey.shade300),
              Expanded(
                child: _buildTeamColumn(
                  match.team2,
                  match.team2Players,
                  match.team2ImageUrl,
                  'team2',
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final canSave =
              controller.selectedTeam1Players.isNotEmpty &&
              controller.selectedTeam2Players.isNotEmpty;
          debugPrint(
            '💾 SquadView: Can save=$canSave (t1=${controller.selectedTeam1Players.length}, t2=${controller.selectedTeam2Players.length})',
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

  Widget _buildTeamColumn(
    String teamName,
    List<String> players,
    String? teamImageUrl,
    String teamId,
  ) {
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
                        child: Icon(
                          Icons.flag_outlined,
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
                  child: Icon(
                    Icons.flag_outlined,
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
                        '$selectedCount/11 selected',
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
                    final playerName = players[index];
                    return Obx(() {
                      final isSelected = controller.isPlayerSelected(
                        playerName,
                        teamId,
                      );
                      return Container(
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
                              color: AppColors.primary.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              debugPrint(
                                '👤 SquadView: Toggling $playerName ($teamId)',
                              );
                              controller.togglePlayerSelection(
                                playerName,
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
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          : Text(
                                              playerName.isNotEmpty
                                                  ? playerName[0].toUpperCase()
                                                  : '?',
                                              style: AppTextStyles.headline2
                                                  .copyWith(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors.primary,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      playerName,
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
                                ],
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
}
