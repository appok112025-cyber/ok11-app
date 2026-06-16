import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/modules/contest/views/team_creation_view.dart';
import 'package:ok11/app/modules/contest/views/leaderboard_view.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/utils/status_theme.dart';

// ----- NEW FRAGMENT VERSION FOR TABS -----
class ContestListViewFragment extends StatefulWidget {
  final MatchData matchData;
  const ContestListViewFragment({Key? key, required this.matchData}) : super(key: key);

  @override
  State<ContestListViewFragment> createState() => _ContestListViewFragmentState();
}

class _ContestListViewFragmentState extends State<ContestListViewFragment> {
  late ContestController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller immediately to avoid LateInitializationError during build
    if (!Get.isRegistered<ContestController>()) {
      Get.put(ContestController());
    }
    controller = Get.find<ContestController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setupForMatch(widget.matchData);
      if (widget.matchData.id != null) {
        controller.fetchContests(widget.matchData.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.contests.isEmpty) {
        return Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.contests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('No contests available', 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 6),
              Text('Check back later for new contests', 
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        itemCount: controller.contests.length,
        itemBuilder: (context, index) {
          final contest = controller.contests[index];
          final isLocked = contest.isLocked;

          final spotsLeft = (contest.participantLimit - contest.totalParticipants).clamp(0, contest.participantLimit);
          final fillPercent = contest.participantLimit > 0
              ? (contest.totalParticipants / contest.participantLimit).clamp(0.0, 1.0)
              : 0.0;
          final isFull = spotsLeft <= 0;

          return GestureDetector(
            onTap: isLocked ? () {
              Get.snackbar('Coming Soon', 'This contest will open soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            } : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLocked ? AppColors.accentGold.withValues(alpha: 0.5) : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          contest.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F1923),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Prize Pool and Join button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRIZE POOL',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${contest.firstPrize.toInt()}', // Simplified for design
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Obx(() {
                                  final hasJoined = controller.joinedContestIds.contains(contest.id);
                                  final isLive = widget.matchData.status != MatchStatus.upcoming;
                                  final cannotJoin = isLocked || (isFull && !hasJoined && !isLive);

                                  return GestureDetector(
                                    onTap: cannotJoin ? null : () {
                                      if (hasJoined || isLive) {
                                        Get.to(() => LeaderboardView(contest: contest, match: widget.matchData));
                                        return;
                                      }
                                      if (!controller.isTeamValid) {
                                        Get.snackbar(
                                          'Team Required',
                                          'Please select your 11 players in the Team tab first.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          colorText: Colors.white,
                                        );
                                        Get.find<MatchDetailController>().onTabChanged(1);
                                        return;
                                      }
                                      if (controller.rxCaptainId.isEmpty || controller.rxViceCaptainId.isEmpty) {
                                        Get.snackbar(
                                          'Captain Required',
                                          'Please select a Captain & Vice Captain first.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          colorText: Colors.white,
                                        );
                                        Get.find<MatchDetailController>().onTabChanged(1);
                                      } else {
                                        controller.joinContest(contest.id);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        hasJoined || isLive ? 'View' : 'Join',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                if (contest.entryFee == 0)
                                  const Text(
                                    'Free',
                                    style: TextStyle(
                                      color: Color(0xFFF0A500),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  )
                                else
                                  Text(
                                    '₹${contest.entryFee.toInt()}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        // Spots
                        Row(
                          children: [
                            Icon(Icons.people_alt, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${contest.participantLimit} spots',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fillPercent,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFull ? Colors.red.shade400 : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Spots filled + spots left
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${contest.totalParticipants} spots filled',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$spotsLeft left',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Text(
                              '1st Prize: ₹${contest.firstPrize.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text(
                              '100% Guaranteed prize',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showPrizePoolBreakdown(BuildContext context, ContestModel contest) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            bottomPadding > 0 ? bottomPadding + 12 : 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prize Pool Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F1923),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, size: 24, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total Prize Pool: ₹${contest.firstPrize.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              if (contest.prizeBreakdown == null || contest.prizeBreakdown!.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(Icons.military_tech, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No prize distribution breakdown configured.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('RANK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primary)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('WINNINGS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primary), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          ...contest.prizeBreakdown!.map((range) {
                            final isFirst = range.fromRank == 1 && range.toRank == 1;
                            final rankText = range.fromRank == range.toRank 
                              ? 'Rank ${range.fromRank}' 
                              : 'Rank ${range.fromRank} - ${range.toRank}';
                              
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      if (isFirst) ...[
                                        const Text('🏆', style: TextStyle(fontSize: 14)),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        rankText,
                                        style: TextStyle(
                                          fontWeight: isFirst ? FontWeight.w900 : FontWeight.w700,
                                          fontSize: 14,
                                          color: isFirst ? const Color(0xFFB8860B) : const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '₹${range.prizeAmount.toInt()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: isFirst ? Colors.green.shade700 : const Color(0xFF1F2937),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
