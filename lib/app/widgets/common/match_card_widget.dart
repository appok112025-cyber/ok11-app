import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/routes/app_pages.dart';

import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/number_formatter.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';
import 'package:ok11/app/widgets/common/team_avatar_widget.dart';

class MatchCardWidget extends StatelessWidget {
  final MatchData match;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool showScoreCard;

  const MatchCardWidget({
    super.key,
    required this.match,
    this.isLoading = false,
    this.onTap,
    this.showScoreCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : onTap ??
                  () {
                    if (match.status == MatchStatus.upcoming) {
                      Get.toNamed(Routes.MATCH_DETAIL, arguments: match);
                    } else if (match.status == MatchStatus.live) {
                      AppSnackbars.showError('Match already started');
                    } else if (match.status == MatchStatus.completed) {
                      AppSnackbars.showError('Match completed');
                    } else if (match.status == MatchStatus.cancelled) {
                      AppSnackbars.showError('Match cancelled');
                    }
                  },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.accentBlue.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      match.title.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TeamAvatarWidget(
                        teamName: match.team1,
                        imageUrl: match.team1ImageUrl,
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accentBlue],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'VS',
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                match.date,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (match.status != MatchStatus.completed) ...[
                                const SizedBox(height: 2),
                                Text(
                                  match.time,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TeamAvatarWidget(
                        teamName: match.team2,
                        imageUrl: match.team2ImageUrl,
                      ),
                    ),
                  ],
                ),
              ),
              if (match.participantsCount != null &&
                  match.participantsCount! > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentGreen.withValues(alpha: 0.1),
                        AppColors.accentTeal.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 18,
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${NumberFormatter.formatCount(match.participantsCount)} ${match.participantsCount == 1 ? 'player' : 'players'} ${match.status == MatchStatus.completed ? 'played' : 'playing'}',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              if (showScoreCard && match.status == MatchStatus.completed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.getGradientWithAlpha(
                        AppColors.successGradient,
                        0.2,
                      ),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentYellow.withValues(alpha: 0.3),
                              AppColors.accentOrange.withValues(alpha: 0.25),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          size: 26,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Score',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${match.score} points',
                                  style: AppTextStyles.headline2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (match.rank != null && match.rank! > 0) ...[
                              Container(
                                height: 32,
                                width: 1.5,
                                color: AppColors.primary.withValues(alpha: 0.15),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Your Rank',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '#${match.rank}',
                                    style: AppTextStyles.headline2.copyWith(
                                      color: AppColors.accentOrange,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
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
}
