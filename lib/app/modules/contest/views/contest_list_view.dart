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
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.contests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_cricket, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text('No contests available for this match currently.', 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
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
                backgroundColor: const Color(0xFFB8860B),
                colorText: Colors.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            } : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLocked ? const Color(0xFFFFD700).withValues(alpha: 0.5) : Colors.grey.shade200,
                  width: isLocked ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top accent bar ──
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      gradient: LinearGradient(
                        colors: isLocked
                            ? [const Color(0xFFFFD700), const Color(0xFFFFC107)]
                            : [AppColors.primary, const Color(0xFF42A5F5)],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name + status chip row ──
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contest.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F1923),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isLocked ? '🔒 COMING SOON' : contest.status.toUpperCase(),
                                style: TextStyle(
                                  color: isLocked ? const Color(0xFFB8860B) : AppColors.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Prize + Entry row ──
                        Row(
                          children: [
                            // Prize Pool
                            Expanded(
                              child: GestureDetector(
                                onTap: isLocked ? null : () => _showPrizePoolBreakdown(context, contest),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PRIZE POOL',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '₹${contest.firstPrize.toInt()}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Icon(Icons.keyboard_arrow_down_rounded,
                                                size: 15, color: Colors.green.shade500),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Divider
                            Container(width: 1, height: 36, color: Colors.grey.shade100),
                            const SizedBox(width: 16),

                            // Entry Fee
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'ENTRY FEE',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (contest.entryFee == 0)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (contest.originalEntryFee > 0) ...[ 
                                        Text(
                                          '₹${contest.originalEntryFee.toInt()}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade400,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'FREE',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    '₹${contest.entryFee.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F1923),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Progress bar ──
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: fillPercent,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFull ? Colors.red.shade400 : AppColors.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Spots row + CTA button ──
                        Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFull
                                  ? 'Full • ${contest.participantLimit} spots'
                                  : '${contest.totalParticipants}/${contest.participantLimit} joined',
                              style: TextStyle(
                                color: isFull ? Colors.red.shade400 : Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Obx(() {
                              final hasJoined = controller.joinedContestIds.contains(contest.id);
                              final isLive = widget.matchData.status != MatchStatus.upcoming;
                              final cannotJoin = isLocked || (isFull && !hasJoined && !isLive);

                              String label;
                              Color bgColor;
                              Color fgColor;

                              if (isLocked) {
                                label = 'SOON';
                                bgColor = Colors.grey.shade100;
                                fgColor = Colors.grey.shade400;
                              } else if (hasJoined || isLive) {
                                label = 'LEADERBOARD';
                                bgColor = AppColors.primary;
                                fgColor = Colors.white;
                              } else if (isFull) {
                                label = 'FULL';
                                bgColor = Colors.grey.shade100;
                                fgColor = Colors.grey.shade400;
                              } else {
                                label = 'JOIN';
                                bgColor = AppColors.primary;
                                fgColor = Colors.white;
                              }

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
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: cannotJoin
                                        ? Border.all(color: Colors.grey.shade200)
                                        : null,
                                    boxShadow: cannotJoin
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                  ),
                                  child: controller.isJoining.value && label == 'JOIN'
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          label,
                                          style: TextStyle(
                                            color: fgColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              );
                            }),
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
          padding: const EdgeInsets.all(24),
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
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
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
                        Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey.shade300),
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
                              color: Colors.grey.shade100,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('RANK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF6B7280))),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('PRIZE AMOUNT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF6B7280)), textAlign: TextAlign.right),
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
                                        const Icon(Icons.emoji_events, size: 16, color: Color(0xFFD4AF37)),
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

// ----- OLD IMPLEMENTATION COMMENTED OUT -----
/*
class ContestListView extends StatefulWidget {
  final MatchData matchData;
  const ContestListView({Key? key, required this.matchData}) : super(key: key);

  @override
  State<ContestListView> createState() => _ContestListViewState();
}

class _ContestListViewState extends State<ContestListView> {
  late ContestController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ContestController>()) {
      Get.put(ContestController());
    }
    controller = Get.find<ContestController>();
    controller.setupForMatch(widget.matchData);
    if (widget.matchData.id != null) {
      controller.fetchContests(widget.matchData.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.contests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.contests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_cricket, size: 64, color: Colors.grey.shade400),
                SizedBox(height: 16),
                Text('No contests available for this match currently.', 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16)
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.contests.length,
          itemBuilder: (context, index) {
            final contest = controller.contests[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(contest.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(contest.status, style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prize Pool', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            Text('₹${contest.firstPrize}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Entry', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            Text('₹${contest.entryFee}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                            SizedBox(width: 4),
                            Text('${contest.totalParticipants} Joined', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                        Row(
                          children: [
                             TextButton(
                              onPressed: () {
                                Get.to(() => LeaderboardView(contest: contest, match: widget.matchData));
                              },
                              child: Text('Leaderboard')
                            ),
                            ElevatedButton(
                              onPressed: () {
                                controller.resetTeam();
                                Get.to(() => TeamCreationView(
                                    matchData: widget.matchData,
                                    contest: contest));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                              child: Text('Join')
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
*/
