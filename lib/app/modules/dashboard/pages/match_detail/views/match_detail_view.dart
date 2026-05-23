import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/views/squad_view.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/views/quiz_view.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/views/score_view.dart';
import 'package:ok11/app/services/submission_service.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/tab_bar_widget.dart';
import 'package:ok11/app/modules/contest/views/contest_list_view.dart';
import 'package:ok11/app/modules/contest/views/team_creation_view.dart';
import 'package:ok11/app/modules/contest/views/leaderboard_view.dart';
import 'package:ok11/app/modules/contest/controllers/contest_controller.dart';

class MatchDetailView extends GetView<MatchDetailController> {
  final String? teams;
  final MatchData? matchData;

  const MatchDetailView({super.key, this.teams, this.matchData});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎯 MatchDetailView.build()');
    if (matchData != null && controller.matchData.value == null) {
      debugPrint(
        '📋 MatchDetailView: Setting match data (id=${matchData?.id})',
      );
      controller.matchData.value = matchData;
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _refreshHomeOnBack();
            Get.back();
          },
        ),
        title: Text(matchData?.title ?? teams ?? 'Match'),
        centerTitle: false,
        /* Appbar contests button disabled as requested
        actions: [
          if (matchData != null)
            Padding(
              ...
              ),
            ),
        ], */
      ),
      body: Column(
        children: [
          Obx(() {
            final match = controller.matchData.value;
            final isLiveOrCompleted =
                match?.status == MatchStatus.live ||
                match?.status == MatchStatus.completed;
            final hasSubmitted = controller.hasSubmitted.value;

            // Disable Squad and Quiz tabs if user has submitted or match is live/completed
            final shouldDisableSquadAndQuiz = isLiveOrCompleted || hasSubmitted;

            return TabBarWidget(
              selectedTab: controller.selectedTab,
              tabs: const ['Contest', 'Team'],
              icons: const [
                Icons.emoji_events_outlined,
                Icons.people_outline_rounded,
              ],
              enabledTabs: [
                true, // Contest always enabled
                true, // Team always enabled
              ],
              onTabChanged: (index) {
                controller.onTabChanged(index);
              },
            );
          }),
          Expanded(child: Obx(() => _buildPage(controller.selectedTab.value))),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    debugPrint('🔄 MatchDetailView._buildPage: $index');
    final match = controller.matchData.value;
    
    if (match == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    switch (index) {
      case 0:
        return ContestListViewFragment(matchData: match);
      case 1:
        return TeamCreationView(matchData: match);
      default:
        return ContestListViewFragment(matchData: match);
    }
  }

  void _refreshHomeOnBack() {
    try {
      final submissionService = Get.find<SubmissionService>();
      submissionService.refreshSubmissions();
      debugPrint('✅ MatchDetailView: Refreshed SubmissionService on back');
    } catch (e) {
      debugPrint('⚠️ MatchDetailView: Failed to refresh SubmissionService: $e');
    }
  }
}
