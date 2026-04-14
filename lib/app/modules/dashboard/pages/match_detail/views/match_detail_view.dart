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
              tabs: const ['Squad', 'Quiz', 'Score'],
              icons: const [
                Icons.people_outline_rounded,
                Icons.quiz_outlined,
                Icons.emoji_events_outlined,
              ],
              enabledTabs: [
                !shouldDisableSquadAndQuiz, // Squad disabled when submitted or live/completed
                !shouldDisableSquadAndQuiz &&
                    controller
                        .canAccessQuiz, // Quiz disabled when submitted or live/completed
                true, // Score always enabled
              ],
              onTabChanged: (index) {
                if (shouldDisableSquadAndQuiz && index != 2) {
                  // Force to Score tab if trying to access disabled tabs
                  controller.selectedTab.value = 2;
                } else {
                  controller.onTabChanged(index);
                }
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
    switch (index) {
      case 0:
        return SquadView();
      case 1:
        return QuizView();
      case 2:
        return const ScoreView();
      default:
        return SquadView();
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
