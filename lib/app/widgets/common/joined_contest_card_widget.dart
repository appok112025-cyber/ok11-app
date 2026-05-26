import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/widgets/common/team_avatar_widget.dart';
import 'package:ok11/app/modules/contest/views/leaderboard_view.dart';
import 'package:ok11/app/utils/status_theme.dart';

class JoinedContestCardWidget extends StatelessWidget {
  final MyJoinedItem item;
  final bool isLoading;

  const JoinedContestCardWidget({
    super.key,
    required this.item,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final match = item.match;
    final contest = item.contest;
    
    final bool isUpcoming = match.status == MatchStatus.upcoming;
    final bool isLive = match.status == MatchStatus.live;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                if (contest != null) {
                  if (isUpcoming) {
                    Get.toNamed(Routes.MATCH_DETAIL, arguments: match);
                  } else {
                    Get.to(() => LeaderboardView(contest: contest, match: match));
                  }
                } else {
                  Get.toNamed(Routes.MATCH_DETAIL, arguments: match);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Match Header VS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      match.title.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? Colors.blue.shade50
                            : isLive
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        match.status.name.toUpperCase(),
                        style: TextStyle(
                          color: isUpcoming
                              ? Colors.blue.shade700
                              : isLive
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Teams Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                        Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match.date,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 3. Contest details section (if present)
              if (contest != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contest.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF0F1923),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'First Prize: ₹${contest.firstPrize.toInt()}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              contest.entryFee == 0 ? 'FREE' : '₹${contest.entryFee.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // 4. Live / Completed stats (rank & points)
                      if (!isUpcoming) ...[
                        const SizedBox(height: 12),
                        () {
                          final double prizeAmount = contest != null
                              ? (contest.prizeBreakdown == null || contest.prizeBreakdown!.isEmpty)
                                  ? (item.rank == 1 ? contest.firstPrize : 0.0)
                                  : contest.prizeBreakdown!
                                      .firstWhere(
                                        (r) => (item.rank ?? 0) >= r.fromRank && (item.rank ?? 0) <= r.toRank,
                                        orElse: () => PrizeRange(fromRank: 0, toRank: 0, prizeAmount: 0.0),
                                      )
                                      .prizeAmount
                              : 0.0;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.emoji_events, size: 16, color: Color(0xFFD4AF37)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Rank: #${item.rank}',
                                      style: const TextStyle(
                                        color: Color(0xFF0F1923),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (prizeAmount > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Won ₹${prizeAmount.toInt()}',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      '${item.points?.toStringAsFixed(1) ?? '0.0'} Pts',
                                      style: const TextStyle(
                                        color: Color(0xFF0F1923),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }(),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                // Quiz submission status
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.quiz_outlined, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quiz Submitted',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
