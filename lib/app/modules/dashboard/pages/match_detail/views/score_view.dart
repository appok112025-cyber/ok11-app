import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';

import 'package:ok11/app/data/models/submission_data.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/team_avatar_widget.dart';

class ScoreView extends GetView<MatchDetailController> {
  const ScoreView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📊 ScoreView.build()');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(
          () => controller.isLoadingScore.value
              ? const Center(child: CircularProgressIndicator())
              : controller.isWaitingForResults
              ? _buildWaitingForResults()
              : controller.hasSubmitted.value &&
                    controller.submissionData.value != null
              ? _buildSubmissionDetails()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No submission data',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWaitingForResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accentBlue.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Wait for Match Results',
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your submission has been recorded.\nResults will be available once the match is completed.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accentBlue.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accentGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submission Confirmed',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (controller.matchData.value?.status !=
                      MatchStatus.live) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          debugPrint('✏️ ScoreView: Edit icon tapped');
                          controller.onTabChanged(0);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionDetails() {
    final submission = controller.submissionData.value!;
    final match = controller.matchData.value!;
    final percentage = submission.scoreSummary?.percentage ?? 0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTeamsWithFlags(match),
              const SizedBox(height: 20),
              if ((submission.totalPointsEarned ?? 0) > 0)
                _buildSubmissionScoreCard(submission.totalPointsEarned!),
              if ((submission.totalPointsEarned ?? 0) > 0)
                const SizedBox(height: 20),
              _buildExpandableSquadCard(submission, match),
              const SizedBox(height: 20),
              _buildExpandableQuizAnswersCard(submission),
              if (match.status != MatchStatus.live &&
                  match.status != MatchStatus.completed) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.accentBlue.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit Submission',
                            style: AppTextStyles.headline2.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You can edit your squad and quiz answers until the match starts',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                debugPrint(
                                  '✏️ ScoreView: Edit Squad button tapped',
                                );
                                controller.onTabChanged(0);
                              },
                              icon: const Icon(Icons.people_rounded, size: 18),
                              label: const Text('Edit Squad'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                debugPrint(
                                  '✏️ ScoreView: Edit Quiz button tapped',
                                );
                                controller.onTabChanged(1);
                              },
                              icon: const Icon(Icons.quiz_rounded, size: 18),
                              label: const Text('Edit Quiz'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if ((submission.totalPointsEarned ?? 0) > 0)
          _ConfettiWidget(
            intensity: _getConfettiIntensityFromPercentage(percentage),
          ),
      ],
    );
  }

  int _getConfettiIntensityFromPercentage(int percentage) {
    if (percentage >= 80) return 3;
    if (percentage >= 50) return 2;
    return 1;
  }

  Widget _buildTeamsWithFlags(MatchData match) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: TeamAvatarWidget(
              teamName: match.team1,
              imageUrl: match.team1ImageUrl,
              size: 64,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VS',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: TeamAvatarWidget(
              teamName: match.team2,
              imageUrl: match.team2ImageUrl,
              size: 64,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionScoreCard(int totalPointsEarned) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withValues(alpha: 0.1),
            AppColors.accentTeal.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 32,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Score',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalPointsEarned points',
                style: AppTextStyles.headline2.copyWith(
                  color: AppColors.accentGreen,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSquadCard(SubmissionData submission, MatchData match) {
    return Obx(() {
      final isExpanded = controller.squadExpanded.value;

      // Get player names - use player objects if available, otherwise lookup from match data
      List<String> getTeamAPlayerNames() {
        // First try to use the populated player objects
        if (submission.teamASelectedPlayerObjects != null &&
            submission.teamASelectedPlayerObjects!.isNotEmpty) {
          return submission.teamASelectedPlayerObjects!
              .map((p) => p.name)
              .toList();
        }
        // Fallback to looking up by ID
        final playerNames = <String>[];
        for (var playerId in submission.teamASelectedPlayers ?? []) {
          final players = match.team1PlayerData.where((p) => p.id == playerId);
          if (players.isNotEmpty) {
            playerNames.add(players.first.name);
          }
        }
        return playerNames;
      }

      List<String> getTeamBPlayerNames() {
        // First try to use the populated player objects
        if (submission.teamBSelectedPlayerObjects != null &&
            submission.teamBSelectedPlayerObjects!.isNotEmpty) {
          return submission.teamBSelectedPlayerObjects!
              .map((p) => p.name)
              .toList();
        }
        // Fallback to looking up by ID
        final playerNames = <String>[];
        for (var playerId in submission.teamBSelectedPlayers ?? []) {
          final players = match.team2PlayerData.where((p) => p.id == playerId);
          if (players.isNotEmpty) {
            playerNames.add(players.first.name);
          }
        }
        return playerNames;
      }

      final teamAPlayers = getTeamAPlayerNames();
      final teamBPlayers = getTeamBPlayerNames();
      final totalPlayers = teamAPlayers.length + teamBPlayers.length;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.squadExpanded.value =
                  !controller.squadExpanded.value,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selected Squad ($totalPlayers)',
                        style: AppTextStyles.headline2.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (teamAPlayers.isNotEmpty) ...[
                      Text(
                        match.team1,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...teamAPlayers.map(
                        (playerName) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    playerName,
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (teamBPlayers.isNotEmpty) ...[
                      Text(
                        match.team2,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...teamBPlayers.map(
                        (playerName) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  color: AppColors.accentBlue,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    playerName,
                                    style: AppTextStyles.body2.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (teamAPlayers.isEmpty && teamBPlayers.isEmpty)
                      Center(
                        child: Text(
                          'No players selected',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildExpandableQuizAnswersCard(SubmissionData submission) {
    final questions = controller.questions;

    return Obx(() {
      final isExpanded = controller.quizExpanded.value;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.quizExpanded.value =
                  !controller.quizExpanded.value,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quiz Answers',
                        style: AppTextStyles.headline2.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: (submission.quizAnswers ?? []).asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final answer = entry.value;
                    final isCorrect = answer.isCorrect ?? false;
                    final points = answer.pointsEarned ?? 0;

                    // Use aggregated data if available, otherwise use questions from controller
                    final questionText =
                        answer.isAggregated && answer.question != null
                        ? answer.question!
                        : (index < questions.length
                              ? questions[index].question
                              : 'Question');

                    // Get all options and indices
                    List<String> allOptions = [];
                    int? selectedIndex;
                    int? correctAnswerIndex;

                    if (answer.isAggregated && answer.options != null) {
                      // Use aggregated options
                      allOptions = answer.options!
                          .map((opt) => opt['text']?.toString() ?? '')
                          .toList();
                      selectedIndex =
                          answer.userSelectedOption ?? answer.selectedOption;
                      correctAnswerIndex = answer.correctAnswer;
                    } else if (index < questions.length) {
                      // Use questions from controller
                      allOptions = questions[index].options;
                      selectedIndex = answer.selectedOption;
                      // For non-aggregated, we don't have correctAnswer info
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questionText,
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? AppColors.accentGreen
                                    : AppColors.accentPink,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCorrect ? '+$points' : '0',
                                style: AppTextStyles.body2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Show all options
                            if (allOptions.isNotEmpty)
                              Column(
                                children: allOptions.asMap().entries.map((
                                  entry,
                                ) {
                                  final optIndex = entry.key;
                                  final optionText = entry.value;
                                  final isSelected =
                                      selectedIndex != null &&
                                      selectedIndex == optIndex;
                                  final isCorrectOption =
                                      correctAnswerIndex != null &&
                                      correctAnswerIndex == optIndex;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: optIndex == allOptions.length - 1
                                          ? 0
                                          : 8,
                                    ),
                                    child: _buildResultOption(
                                      optionText,
                                      isSelected,
                                      isCorrectOption,
                                      isCorrect,
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildResultOption(
    String optionText,
    bool isSelected,
    bool isCorrectOption,
    bool isAnswerCorrect,
  ) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    Widget? leadingIcon;
    String? label;

    if (isSelected && isAnswerCorrect) {
      // User selected correct answer
      backgroundColor = AppColors.accentGreen.withValues(alpha: 0.15);
      textColor = AppColors.accentGreen;
      borderColor = AppColors.accentGreen;
      leadingIcon = Icon(
        Icons.check_circle_rounded,
        color: AppColors.accentGreen,
        size: 20,
      );
      label = 'Your Answer (Correct)';
    } else if (isSelected && !isAnswerCorrect) {
      // User selected wrong answer
      backgroundColor = AppColors.accentPink.withValues(alpha: 0.15);
      textColor = AppColors.accentPink;
      borderColor = AppColors.accentPink;
      leadingIcon = Icon(
        Icons.cancel_rounded,
        color: AppColors.accentPink,
        size: 20,
      );
      label = 'Your Answer (Wrong)';
    } else if (isCorrectOption && !isAnswerCorrect) {
      // Correct answer (when user was wrong)
      backgroundColor = AppColors.accentGreen.withValues(alpha: 0.15);
      textColor = AppColors.accentGreen;
      borderColor = AppColors.accentGreen;
      leadingIcon = Icon(
        Icons.check_circle_rounded,
        color: AppColors.accentGreen,
        size: 20,
      );
      label = 'Correct Answer';
    } else {
      // Other options
      backgroundColor = AppColors.surfaceVariant;
      textColor = AppColors.textSecondary;
      borderColor = AppColors.primary.withValues(alpha: 0.1);
      leadingIcon = null;
      label = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            leadingIcon,
            const SizedBox(width: 8),
          ] else ...[
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              optionText,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfettiWidget extends StatefulWidget {
  final int intensity;

  const _ConfettiWidget({this.intensity = 1});

  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    final particleCount = 30 + (widget.intensity * 20);
    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1 - _random.nextDouble() * 0.3,
          color: _getRandomColor(),
          size: 8 + _random.nextDouble() * 8,
          speed: 0.3 + _random.nextDouble() * 0.4,
          angle: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        ),
      );
    }

    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.y += particle.speed * 0.016;
          particle.x += sin(particle.angle) * 0.01;
          particle.angle += particle.rotationSpeed;
          if (particle.y > 1.2) {
            particle.y = -0.1;
            particle.x = _random.nextDouble();
          }
        }
      });
    });
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.primary,
      AppColors.accentYellow,
      AppColors.accentOrange,
      AppColors.accentGreen,
      AppColors.accentPink,
      AppColors.accentPurple,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  Color color;
  double size;
  double speed;
  double angle;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.angle);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
