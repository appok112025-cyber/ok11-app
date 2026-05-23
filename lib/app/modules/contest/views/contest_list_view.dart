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
        padding: const EdgeInsets.all(16),
        itemCount: controller.contests.length,
        itemBuilder: (context, index) {
          final contest = controller.contests[index];
          final isLocked = contest.isLocked;
          
          return Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isLocked ? const Color(0xFFFFD700) : Colors.grey.shade200,
                width: isLocked ? 2 : 1,
              )
            ),
            child: Container(
              decoration: isLocked ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.05),
                    Colors.white,
                  ],
                ),
              ) : null,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(contest.name, 
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0F1923), fontWeight: FontWeight.w900)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLocked ? const Color(0xFFFFD700).withValues(alpha: 0.1) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: isLocked ? Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)) : null,
                        ),
                        child: Text(isLocked ? 'COMING SOON' : contest.status.toUpperCase(), 
                          style: TextStyle(
                            color: isLocked ? const Color(0xFFB8860B) : Colors.blue.shade700, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: 0.5
                          )
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: isLocked ? null : () => _showPrizePoolBreakdown(context, contest),
                        child: Container(
                          color: Colors.transparent, // Expand tap target
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('PRIZE POOL', 
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.info_outline, size: 12, color: Colors.grey.shade400),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('₹${contest.firstPrize.toInt()}', 
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green.shade700)),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('ENTRY FEE', 
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          if (contest.entryFee == 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (contest.originalEntryFee > 0) ...[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        '₹${contest.originalEntryFee.toInt()}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Container(
                                            height: 1.5,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C853), Color(0xFF64DD17)],
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
                            Text('₹${contest.entryFee.toInt()}', 
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F1923))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar & Spots Left Section
                  () {
                    final spotsLeft = (contest.participantLimit - contest.totalParticipants).clamp(0, contest.participantLimit);
                    final fillPercent = (contest.totalParticipants / contest.participantLimit).clamp(0.0, 1.0);
                    final isFull = spotsLeft <= 0;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fillPercent,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFull ? Colors.red.shade600 : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isFull ? 'Contest Full' : '$spotsLeft spots left',
                              style: TextStyle(
                                color: isFull ? Colors.red.shade700 : AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${contest.participantLimit} spots',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }(),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade100, thickness: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_alt_rounded, size: 18, color: Colors.grey.shade400),
                          const SizedBox(width: 8),
                          Text('${contest.totalParticipants} Joined', 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Obx(() {
                        final hasJoined = controller.joinedContestIds.contains(contest.id);
                        final isLive = widget.matchData.status != MatchStatus.upcoming;
                        final isFull = contest.totalParticipants >= contest.participantLimit;
                        
                        return ElevatedButton(
                          onPressed: isLocked || (isFull && !hasJoined) ? null : () {
                            if (hasJoined) {
                              Get.to(() => LeaderboardView(contest: contest, match: widget.matchData));
                              return;
                            }
                            if (isLive) {
                              Get.snackbar('Match Started', 'You can no longer join this contest.',
                                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade700, colorText: Colors.white);
                              return;
                            }
                            if (!controller.isTeamValid) {
                              Get.snackbar('Team Required', 'Please select your 11 players in the Team tab first.', 
                                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                              Get.find<MatchDetailController>().onTabChanged(1); // Redirect to Team tab (index 1)
                              return;
                            }
                            if (controller.rxCaptainId.isEmpty || controller.rxViceCaptainId.isEmpty) {
                              Get.snackbar('Captain Required', 'Please select a Captain & Vice Captain first.', 
                                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                              Get.find<MatchDetailController>().onTabChanged(1); // Redirect to Team tab (index 1)
                            } else {
                              controller.joinContest(contest.id).then((success) {
                                if (success) {
                                  // Just stay on Contest page, and the button will automatically show LEADERBOARD
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLocked || (isFull && !hasJoined)
                              ? Colors.grey.shade100
                              : hasJoined 
                                ? Colors.blue.shade600 
                                : isLive 
                                  ? Colors.grey.shade300 
                                  : AppColors.primary,
                            foregroundColor: isLocked || (isFull && !hasJoined)
                              ? Colors.grey.shade400
                              : isLive && !hasJoined ? Colors.grey.shade600 : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: isLocked || (isFull && !hasJoined) ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                            )
                          ),
                          child: controller.isJoining.value 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : Text(
                                  isLocked
                                    ? 'COMING SOON'
                                    : hasJoined 
                                      ? 'LEADERBOARD' 
                                      : isLive 
                                          ? 'MATCH STARTED' 
                                          : isFull 
                                              ? 'CONTEST FULL'
                                              : 'JOIN NOW', 
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        );
                      })
                    ],
                  )
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
