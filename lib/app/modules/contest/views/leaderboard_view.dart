import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/repositories/match_repository.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/modules/contest/views/squad_preview_view.dart';
import 'package:ok11/app/modules/contest/views/team_creation_view.dart';
import 'package:ok11/app/modules/contest/views/team_creation_view.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/widgets/common/tab_bar_widget.dart';


Future<void> _viewUserSquad(BuildContext context, LeaderboardEntryModel entry, [ContestModel? contest]) async {
  // 1. Find MatchDetailController to check match status
  if (!Get.isRegistered<MatchDetailController>()) {
    Get.snackbar(
      'Error',
      'Match details not loaded.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
    );
    return;
  }
  
  final matchDetailCtrl = Get.find<MatchDetailController>();
  MatchData? match = matchDetailCtrl.matchData.value;
  if (match == null) return;

  final contestCtrl = Get.find<ContestController>();
  final currentUserId = contestCtrl.authStore.user.value?.id;
  final isMySquad = entry.userId == currentUserId;

  // 2. Check if the match is started (squads are locked for others)
  final isStarted = match.status != MatchStatus.upcoming;
  if (!isStarted && !isMySquad) {
    Get.snackbar(
      'Squad Locked',
      'Squads will be visible once the match starts!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
    return;
  }

  // 3. Ensure player data is loaded
  if (contestCtrl.allPlayerInfo.isEmpty && match.id != null) {
    final fullMatch = await MatchRepository().getMatchById(match.id!);
    if (fullMatch != null) {
      match = fullMatch;
      matchDetailCtrl.matchData.value = fullMatch;
      contestCtrl.setupForMatch(fullMatch);
    }
  }

  // 4. Map leaderboard player IDs to PlayerInfo objects
  final playersList = entry.players.map((id) {
    return contestCtrl.allPlayerInfo.firstWhereOrNull((p) => p.id == id);
  }).whereType<PlayerInfo>().toList();

  if (entry.players.isEmpty) {
    Get.snackbar(
      'Unavailable',
      'This user has not selected a squad yet.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
    );
    return;
  }

  // 5. Open SquadPreviewView
  Get.to(() => SquadPreviewView(
    userName: entry.userName,
    teamLabel: 'T1',
    totalPoints: entry.points,
    match: match!,
    players: playersList,
    captainId: entry.captainId,
    viceCaptainId: entry.viceCaptainId,
  ));
}

Widget _buildEmptyState() {
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
          child: Icon(Icons.military_tech, size: 56, color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 20),
        const Text(
          'NOT JOINED YET',
          style: TextStyle(color: Color(0xFF0F1923), fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Join a contest to see your rank and compete with others!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

Widget _buildUserStatsHeader(LeaderboardEntryModel? myEntry) {
  String subText = 'Keep it up! Push to the top!';
  if (myEntry != null) {
    if (myEntry.rank == 1) {
      subText = '👑 Congratulations! You are at the top!';
    } else if (myEntry.rank <= 3) {
      subText = '🔥 Outstanding! You are on the podium!';
    } else if (myEntry.rank <= 10) {
      subText = 'Keep it up! You\'re in the top 10%';
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT RANK',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myEntry != null ? '#${myEntry.rank}' : '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'TOTAL POINTS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myEntry != null ? myEntry.points.toStringAsFixed(0) : '0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          subText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

double getPrizeForRank(int rank, ContestModel? contest) {
  if (contest == null || contest.prizeBreakdown == null || contest.prizeBreakdown!.isEmpty) {
    return rank == 1 ? contest?.firstPrize ?? 0.0 : 0.0;
  }
  for (final range in contest.prizeBreakdown!) {
    if (rank >= range.fromRank && rank <= range.toRank) {
      return range.prizeAmount;
    }
  }
  return 0.0;
}

Widget _buildPodium(BuildContext context, List<LeaderboardEntryModel> entries, String? currentUserId, ContestModel? contest) {
  if (entries.isEmpty) return const SizedBox();
  
  final first = entries[0];
  final second = entries.length >= 2 ? entries[1] : null;
  final third = entries.length >= 3 ? entries[2] : null;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place - left
        Expanded(
          child: second != null
              ? _buildPodiumItem(context, second, 2, currentUserId, const Color(0xFFC0C0C0), 85, contest)
              : const SizedBox(),
        ),
        const SizedBox(width: 12),
        // 1st place - center
        Expanded(
          child: _buildPodiumItem(context, first, 1, currentUserId, AppColors.accentGold, 105, contest),
        ),
        const SizedBox(width: 12),
        // 3rd place - right
        Expanded(
          child: third != null
              ? _buildPodiumItem(context, third, 3, currentUserId, const Color(0xFFCD7F32), 85, contest)
              : const SizedBox(),
        ),
      ],
    ),
  );
}

Widget _buildPodiumItem(BuildContext context, LeaderboardEntryModel entry, int rank, String? currentUserId, Color ringColor, double cardHeight, ContestModel? contest) {
  final isMe = entry.userId == currentUserId;
  final isRank1 = rank == 1;
  
  Widget medalIcon;
  if (rank == 1) {
    medalIcon = const Icon(Icons.workspace_premium, color: AppColors.accentGold, size: 14);
  } else if (rank == 2) {
    medalIcon = const Icon(Icons.workspace_premium, color: Color(0xFFC0C0C0), size: 12);
  } else {
    medalIcon = const Icon(Icons.workspace_premium, color: Color(0xFFCD7F32), size: 12);
  }

  return GestureDetector(
    onTap: () => _viewUserSquad(context, entry, contest),
    child: Column(
      mainAxisSize: MainAxisSize.min,
    children: [
      // Avatar with Medal badge
      Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: isRank1 ? 72 : 60,
            height: isRank1 ? 72 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 2.5),
              color: Colors.white,
            ),
            child: ClipOval(
              child: entry.userName.isNotEmpty
                  ? Center(
                      child: Text(
                        entry.userName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: isRank1 ? 26 : 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.grey, size: 24),
            ),
          ),
          // Medal Badge on bottom right
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: medalIcon,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Card underneath
      Container(
        height: cardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRank1 ? AppColors.primary : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#$rank',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isMe ? 'YOU' : entry.userName,
              style: TextStyle(
                color: const Color(0xFF0F1923),
                fontSize: isRank1 ? 12 : 11,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              entry.points.toStringAsFixed(0),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: isRank1 ? 13 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ]
    ),
  );
}

Widget _buildLeaderboardTile(BuildContext context, LeaderboardEntryModel entry, bool isMe, ContestModel? contest) {
  final prizeAmount = getPrizeForRank(entry.rank, contest);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isMe ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE5E7EB),
        width: 1.2,
      ),
    ),
    child: ListTile(
      onTap: () => _viewUserSquad(context, entry, contest),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '#${entry.rank}',
            style: TextStyle(
              color: isMe ? AppColors.primary : Colors.grey.shade700,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
      title: Text(
        isMe ? 'YOU (${entry.userName})' : entry.userName,
        style: TextStyle(
          color: const Color(0xFF0F1923),
          fontSize: 14,
          fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      trailing: Row(
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
                '₹${prizeAmount.toInt()}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            '${entry.points.toStringAsFixed(1)} PTS',
            style: const TextStyle(
              color: Color(0xFF0F1923),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRankingListCard(BuildContext context, List<LeaderboardEntryModel> entries, String? currentUserId, ContestModel? contest) {
  final startIndex = entries.length >= 3 ? 3 : entries.length;
  final remainingEntries = entries.sublist(startIndex);

  if (remainingEntries.isEmpty) return const SizedBox();

  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header label
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Text(
            'RANKING LIST',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
        // Items
        ...List.generate(remainingEntries.length, (index) {
          final entry = remainingEntries[index];
          final isMe = entry.userId == currentUserId;

          return Column(
            children: [
              if (index > 0)
                Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
              GestureDetector(
                onTap: () => _viewUserSquad(context, entry, contest),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      // Rank number
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${entry.rank}',
                          style: TextStyle(
                            color: isMe ? AppColors.primary : const Color(0xFF374151),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: isMe ? AppColors.primary : Colors.grey.shade600,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Username
                      Expanded(
                        child: Text(
                          isMe ? 'YOU (${entry.userName})' : entry.userName,
                          style: TextStyle(
                            color: const Color(0xFF0F1923),
                            fontSize: 14,
                            fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                      ),
                      // Points — bold, right-aligned
                      Text(
                        entry.points.toStringAsFixed(0),
                        style: TextStyle(
                          color: isMe ? AppColors.primary : const Color(0xFF0F1923),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        // View More Users
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'View More Users',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );
}


class LeaderboardViewFragment extends StatefulWidget {
  const LeaderboardViewFragment({Key? key}) : super(key: key);

  @override
  State<LeaderboardViewFragment> createState() => _LeaderboardViewFragmentState();
}

class _LeaderboardViewFragmentState extends State<LeaderboardViewFragment> {
  late ContestController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ContestController>();
    if (controller.joinedContestIds.isNotEmpty && controller.leaderboard.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchLeaderboard(controller.joinedContestIds.first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Get.find<AuthStore>();
    final currentUserId = authStore.user.value?.id;

    return Container(
      color: AppColors.background,
      child: Obx(() {
        if (controller.isLoading.value && controller.leaderboard.isEmpty) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.joinedContestIds.isEmpty) {
          return _buildEmptyState();
        }

        final myEntry = controller.leaderboard.firstWhereOrNull((e) => e.userId == currentUserId);

        return RefreshIndicator(
          onRefresh: () async => controller.fetchLeaderboard(controller.joinedContestIds.first),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // User Stats Header
              SliverToBoxAdapter(
                child: _buildUserStatsHeader(myEntry),
              ),
              
              // Top 3 Podium
              if (controller.leaderboard.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildPodium(
                    context,
                    controller.leaderboard.take(3).toList(),
                    currentUserId,
                    controller.contests.firstWhereOrNull((c) => c.id == controller.joinedContestIds.first),
                  ),
                ),
              
              // Remaining participants
              SliverToBoxAdapter(
                child: _buildRankingListCard(
                  context,
                  controller.leaderboard,
                  currentUserId,
                  controller.contests.firstWhereOrNull((c) => c.id == controller.joinedContestIds.first),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}


class LeaderboardView extends StatefulWidget {
  final ContestModel contest;
  final MatchData match;
  const LeaderboardView({Key? key, required this.contest, required this.match}) : super(key: key);

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  late ContestController controller;
  final authStore = Get.find<AuthStore>();
  final selectedTab = 0.obs;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ContestController>()) {
      Get.put(ContestController());
    }
    if (!Get.isRegistered<MatchDetailController>()) {
      final detailCtrl = Get.put(MatchDetailController());
      detailCtrl.matchData.value = widget.match;
    } else {
      Get.find<MatchDetailController>().matchData.value = widget.match;
    }
    controller = Get.find<ContestController>();
    controller.setupForMatch(widget.match);
    controller.fetchLeaderboard(widget.contest.id);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = authStore.user.value?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.contest.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          TabBarWidget(
            selectedTab: selectedTab,
            tabs: const ['Prize Distribution', 'Leaderboard'],
            onTabChanged: (index) {
              selectedTab.value = index;
            },
          ),
          Expanded(
            child: Obx(() {
              if (selectedTab.value == 0) {
                return SingleChildScrollView(
                  child: _buildPrizeBreakdown(widget.contest),
                );
              } else {
                if (controller.isLoading.value && controller.leaderboard.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (controller.leaderboard.isEmpty) {
                  return const Center(
                    child: Text(
                      'No participants yet.',
                      style: TextStyle(color: Color(0xFF0F1923)),
                    ),
                  );
                }

                final myEntry = controller.leaderboard.firstWhereOrNull(
                  (e) => e.userId == currentUserId,
                );

                return RefreshIndicator(
                  onRefresh: () async =>
                      controller.fetchLeaderboard(widget.contest.id),
                  color: AppColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      // User Stats Header
                      SliverToBoxAdapter(
                        child: _buildUserStatsHeader(myEntry),
                      ),

                      // Top 3 Podium
                      if (controller.leaderboard.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildPodium(
                            context,
                            controller.leaderboard.take(3).toList(),
                            currentUserId,
                            widget.contest,
                          ),
                        ),

                      // Remaining Participants
                      SliverToBoxAdapter(
                        child: _buildRankingListCard(
                          context,
                          controller.leaderboard,
                          currentUserId,
                          widget.contest,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeBreakdown(ContestModel contest) {
    final hasBreakdown = contest.prizeBreakdown != null && contest.prizeBreakdown!.isNotEmpty;
    final effectiveBreakdown = hasBreakdown
        ? contest.prizeBreakdown!
        : [
            PrizeRange(fromRank: 1, toRank: 1, prizeAmount: contest.firstPrize),
          ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1),
            },
            children: [
              // Header row
              TableRow(
                decoration: const BoxDecoration(color: AppColors.primary),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('RANK',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      )),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('WINNINGS',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      )),
                  ),
                ],
              ),
              // Data rows
              ...effectiveBreakdown.asMap().entries.map((entry) {
                final range = entry.value;
                final isFirst = range.fromRank == 1 && range.toRank == 1;
                final rankText = range.fromRank == range.toRank
                    ? 'Rank ${range.fromRank}'
                    : 'Rank ${range.fromRank} - ${range.toRank}';

                return TableRow(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        children: [
                          Text(
                            rankText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Text(
                        '₹${_formatAmount(range.prizeAmount.toInt())}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isFirst ? Colors.green.shade700 : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(0)} Lakh';
    } else if (amount >= 1000) {
      // Format with commas like Indian system
      final s = amount.toString();
      return s;
    }
    return amount.toString();
  }
}
