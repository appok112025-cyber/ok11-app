
import 'dart:ui';
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
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text('Check back later for new contests',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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

          final spotsLeft = (contest.participantLimit - contest.totalParticipants)
              .clamp(0, contest.participantLimit);
          final fillPercent = contest.participantLimit > 0
              ? (contest.totalParticipants / contest.participantLimit).clamp(0.0, 1.0)
              : 0.0;
          final isFull = spotsLeft <= 0;

          // Build the base card widget
          final Widget cardBody = Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLocked
                    ? const Color(0xFFD4AF37)
                    : Colors.grey.shade200,
                width: isLocked ? 3.0 : 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Card Body ──────────────────────────────────────────
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

                        // Prize Pool + Join/View button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prize Pool
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
                                  '₹${contest.firstPrize.toInt()}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            // Join / View button + entry fee
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Obx(() {
                                  final hasJoined =
                                      controller.joinedContestIds.contains(contest.id);
                                  final isLive =
                                      widget.matchData.status != MatchStatus.upcoming;
                                  final cannotJoin =
                                      isLocked || (isFull && !hasJoined && !isLive);

                                  return GestureDetector(
                                    onTap: cannotJoin
                                        ? null
                                        : () {
                                            if (hasJoined || isLive) {
                                              Get.to(() => LeaderboardView(
                                                    contest: contest,
                                                    match: widget.matchData,
                                                  ));
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
                                              Get.find<MatchDetailController>()
                                                  .onTabChanged(1);
                                              return;
                                            }
                                            if (controller.rxCaptainId.isEmpty ||
                                                controller.rxViceCaptainId.isEmpty) {
                                              Get.snackbar(
                                                'Captain Required',
                                                'Please select a Captain & Vice Captain first.',
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.orange,
                                                colorText: Colors.white,
                                              );
                                              Get.find<MatchDetailController>()
                                                  .onTabChanged(1);
                                            } else {
                                              controller.joinContest(contest.id);
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 7),
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

                        // Spots count
                        Row(
                          children: [
                            Icon(Icons.people_alt,
                                size: 14, color: Colors.grey.shade600),
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

                        // Spots filled / left
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

                  // ── Footer ────────────────────────────────────────────
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: AppColors.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: guaranteed prize badge
                        const Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '100% Guaranteed prize',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),

                        // Right: Prize Distribution info button
                        GestureDetector(
                          onTap: () =>
                              _showPrizePoolBreakdown(context, contest),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Prize Distribution',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            

          // ── Non-locked: return card as-is ─────────────────────────────
          if (!isLocked) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: cardBody,
            );
          }

          // ── Locked: card + centred gold-green lock icon ───────────────
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: [
                cardBody,

                // Subtle blur over the locked card body
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),

                // Centred gold lock icon inspired by AR Arena play button
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                          border: Border.all(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.6),
                            width: 2.0,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFB800),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tap handler for locked state - showing premium dialog
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _showPremiumLockedDialog(context, contest);
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
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
                    icon: Icon(Icons.cancel,
                        size: 24, color: Colors.grey.shade600),
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
              if (contest.prizeBreakdown == null ||
                  contest.prizeBreakdown!.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(Icons.military_tech,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No prize distribution breakdown configured.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
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
                              child: Text('RANK',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: AppColors.primary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('WINNINGS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: AppColors.primary),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                        ...contest.prizeBreakdown!.map((range) {
                          final isFirst =
                              range.fromRank == 1 && range.toRank == 1;
                          final rankText = range.fromRank == range.toRank
                              ? 'Rank ${range.fromRank}'
                              : 'Rank ${range.fromRank} - ${range.toRank}';

                          return TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade100,
                                      width: 0.5)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  rankText,
                                  style: TextStyle(
                                    fontWeight: isFirst
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    fontSize: 14,
                                    color: isFirst
                                        ? const Color(0xFFB8860B)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '₹${range.prizeAmount.toInt()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: isFirst
                                        ? Colors.green.shade700
                                        : const Color(0xFF1F2937),
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

  void _showPremiumLockedDialog(BuildContext context, ContestModel contest) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Color(0xFFE5A93B), // Premium Gold Border
              width: 2.0,
            ),
          ),
          backgroundColor: const Color(0xFF11141B), // Luxurious Dark Background
          surfaceTintColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  const Color(0xFF251F14), // Subtle gold glow at top
                  const Color(0xFF11141B), // Solid dark bottom
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown Icon with glow effect
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5A93B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5A93B).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 50,
                    color: Color(0xFFFFAE19), // Vivid premium golden
                  ),
                ),
                const SizedBox(height: 24),
                
                // Premium Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFAE19), Color(0xFFE5A93B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PREMIUM CONTEST',
                    style: TextStyle(
                      color: Color(0xFF11141B),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  contest.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Status - Coming Soon
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: const Color(0xFFFFAE19).withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Explanation text
                const Text(
                  'This exclusive premium contest will unlock shortly! Get your teams ready to compete for elite rewards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFA0A5B5),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Close button with golden styling
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF11141B),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFAE19), Color(0xFFE5A93B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5A93B).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'GOT IT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
