import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/contest_model.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/data/repositories/match_repository.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';
import 'package:ok11/app/modules/contest/views/squad_preview_view.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/stores/auth_store.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/utils/player_utils.dart';

// ── SHARED LEADERBOARD BUILDERS ───────────────────────────────────

Future<void> _viewUserSquad(BuildContext context, LeaderboardEntryModel entry) async {
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

  // 2. Check if the match is started (i.e. status is not upcoming)
  final isStarted = match.status != MatchStatus.upcoming;
  if (!isStarted) {
    Get.snackbar(
      'Squad Locked',
      'Squads will be visible once the match starts!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFD97706),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
    return;
  }

  // 3. Ensure player data is loaded
  final contestCtrl = Get.find<ContestController>();
  
  // If allPlayerInfo is empty, the match was opened without full player data.
  // Fetch the full match (which includes populated player objects) on demand.
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
        Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem('MY RANK', '#${myEntry?.rank ?? '-'}'),
        _divider(),
        _statItem('MY POINTS', '${myEntry?.points.toStringAsFixed(1) ?? '0'}'),
      ],
    ),
  );
}

Widget _statItem(String label, String value) {
  return Column(
    children: [
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Color(0xFF0F1923), fontSize: 28, fontWeight: FontWeight.w900)),
    ],
  );
}

Widget _divider() {
  return Container(height: 40, width: 1, color: Colors.grey.shade200);
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

Widget _buildLeaderboardTile(BuildContext context, LeaderboardEntryModel entry, bool isMe, ContestModel? contest) {
  final prizeAmount = getPrizeForRank(entry.rank, contest);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: isMe ? Colors.green.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isMe ? Colors.green.shade200 : Colors.grey.shade200,
        width: isMe ? 1.5 : 1,
      ),
    ),
    child: ListTile(
      onTap: () => _viewUserSquad(context, entry),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: entry.rank <= 3 ? Colors.amber.shade50 : Colors.grey.shade50,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '#${entry.rank}',
            style: TextStyle(
              color: entry.rank <= 3 ? Colors.amber.shade800 : Colors.grey.shade600,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ),
      title: Text(
        isMe ? 'YOU (${entry.userName})' : entry.userName.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF0F1923),
          fontSize: 14,
          fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.points.toStringAsFixed(1)} PTS',
              style: const TextStyle(
                color: Color(0xFF0F1923),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          if (prizeAmount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '₹${prizeAmount.toInt()}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ── 1. LEADERBOARD TAB FRAGMENT ───────────────────────────────────

class LeaderboardViewFragment extends StatelessWidget {
  const LeaderboardViewFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContestController>();
    final authStore = Get.find<AuthStore>();
    final currentUserId = authStore.user.value?.id;

    // Trigger leaderboard fetch if we have joined contests but no leaderboard yet
    if (controller.joinedContestIds.isNotEmpty && controller.leaderboard.isEmpty) {
      Future.microtask(() => controller.fetchLeaderboard(controller.joinedContestIds.first));
    }

    return Container(
      color: Colors.grey.shade50,
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
          child: CustomScrollView(
            slivers: [
              // User Stats Header
              SliverToBoxAdapter(
                child: _buildUserStatsHeader(myEntry),
              ),
              
              // Participants List
              if (controller.leaderboard.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No participants found', style: TextStyle(color: Color(0xFF0F1923)))),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = controller.leaderboard[index];
                      final isMe = entry.userId == currentUserId;
                      final contest = controller.contests.firstWhereOrNull((c) => c.id == controller.joinedContestIds.first);
                      return _buildLeaderboardTile(context, entry, isMe, contest);
                    },
                    childCount: controller.leaderboard.length,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ── 2. LEADERBOARD STANDALONE VIEW SCREEN ──────────────────────────

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(widget.contest.name),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'LEADERBOARD'),
              Tab(text: 'PRIZE DISTRIBUTION'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Leaderboard
            Obx(() {
              if (controller.isLoading.value && controller.leaderboard.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.leaderboard.isEmpty) {
                return const Center(child: Text('No participants yet.', style: TextStyle(color: Color(0xFF0F1923))));
              }

              final myEntry = controller.leaderboard.firstWhereOrNull((e) => e.userId == currentUserId);

              return RefreshIndicator(
                onRefresh: () async => controller.fetchLeaderboard(widget.contest.id),
                child: CustomScrollView(
                  slivers: [
                    // User Stats Header
                    SliverToBoxAdapter(
                      child: _buildUserStatsHeader(myEntry),
                    ),

                    // Participants List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = controller.leaderboard[index];
                          final isMe = entry.userId == currentUserId;
                          return _buildLeaderboardTile(context, entry, isMe, widget.contest);
                        },
                        childCount: controller.leaderboard.length,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Tab 2: Prize Distribution
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildPrizeBreakdown(widget.contest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeBreakdown(ContestModel contest) {
    // Build a default single-winner breakdown if none is configured
    final hasBreakdown = contest.prizeBreakdown != null && contest.prizeBreakdown!.isNotEmpty;
    final effectiveBreakdown = hasBreakdown
        ? contest.prizeBreakdown!
        : [
            PrizeRange(fromRank: 1, toRank: 1, prizeAmount: contest.firstPrize),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasBreakdown)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prize breakdown not configured. Showing default: winner takes all.',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade800, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Total Prize Pool: ₹${contest.firstPrize.toInt()}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
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
                ...effectiveBreakdown.map((range) {
                  final isFirst = range.fromRank == 1 && range.toRank == 1;
                  final rankText = range.fromRank == range.toRank 
                    ? 'Rank ${range.fromRank}' 
                    : 'Rank ${range.fromRank} - ${range.toRank}';
                    
                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
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
    );
  }
}
