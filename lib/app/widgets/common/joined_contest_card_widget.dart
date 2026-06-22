import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/theme/app_colors.dart';
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
    final bool isCompleted = match.status == MatchStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading
              ? null
              : () {
                  Get.toNamed(Routes.MATCH_DETAIL, arguments: match);
                },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Series Name
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Text(
                  match.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
              // Teams Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    // Team 1
                    Expanded(
                      child: _buildTeam(match.team1, match.team1ImageUrl),
                    ),
                    
                    // VS or Date/Time section
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                              children: [
                                TextSpan(text: '${match.date}, '),
                                TextSpan(
                                  text: match.time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Team 2
                    Expanded(
                      child: _buildTeam(match.team2, match.team2ImageUrl),
                    ),

                    // Completed stats on the right side if completed
                    if (isCompleted) ...[
                      const SizedBox(),
                    ],
                  ],
                ),
              ),
              
              // Bottom Section (Live/Completed)
              if (isLive || isCompleted) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
                if (isLive)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Teams',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '1 Team',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contests',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.contestCount} ${item.contestCount == 1 ? "Contest" : "Contests"}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isCompleted)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rank #${item.rank ?? 0}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
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
                              return Text(
                                'Won ₹${prizeAmount.toInt()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              );
                            }(),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Fan engage points',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${item.points?.toStringAsFixed(0) ?? '0'} pts',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(String teamName, String? imageUrl) {
    final isNz = teamName.toUpperCase() == 'NZ';
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isNz ? Colors.black : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isNz ? Colors.black : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: ClipOval(
            child: Padding(
              padding: isNz ? const EdgeInsets.all(4) : const EdgeInsets.all(0),
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: isNz ? BoxFit.cover : BoxFit.contain,
                      errorBuilder: (c, e, s) => Center(
                        child: Icon(Icons.person, color: Colors.grey.shade300, size: 32),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.person, color: Colors.grey.shade300, size: 32),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          teamName.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F2937),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
