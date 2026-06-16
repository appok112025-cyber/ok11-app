import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/routes/app_pages.dart';

import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/app_snackbars.dart';

class MatchCardWidget extends StatelessWidget {
  final MatchData match;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool showScoreCard;
  final bool isLive;
  final bool isCompleted;

  const MatchCardWidget({
    super.key,
    required this.match,
    this.isLoading = false,
    this.onTap,
    this.showScoreCard = false,
    this.isLive = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                          if (!isLive && !isCompleted && match.status != MatchStatus.completed && match.status != MatchStatus.live) ...[
                            const SizedBox(height: 14),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                                children: [
                                  const TextSpan(text: 'Today, '),
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
                        ],
                      ),
                    ),

                    // Team 2
                    Expanded(
                      child: _buildTeam(match.team2, match.team2ImageUrl),
                    ),
                    
                    // Completed specific data on the right
                    if (isCompleted) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Won ₹120',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rank #45',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
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
                                  '2 Contests',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
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
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                          '650 pts',
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
