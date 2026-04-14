import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/match_detail/controllers/match_detail_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/widgets/common/save_proceed_button.dart';

class QuizView extends GetView<MatchDetailController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎯 QuizView.build()');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final match = controller.matchData.value;
          if (match == null) {
            return const Center(child: Text('No match data available'));
          }
          final questions = controller.questions;
          if (questions.isEmpty) {
            return const Center(child: Text('No quiz questions available'));
          }
          return Column(
            children: [
              _buildHeader(questions.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final questionId = 'quiz_$index';
                    debugPrint(
                      '📝 QuizView: Building question ${index + 1}/${questions.length}',
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildQuestion(
                        questionId,
                        index + 1,
                        questions.length,
                        question.question,
                        question.options,
                      ),
                    );
                  },
                ),
              ),
              Obx(() {
                final canSave =
                    controller.selectedQuizAnswers.length >= questions.length;
                debugPrint(
                  '💾 QuizView: Can save=$canSave (${controller.selectedQuizAnswers.length}/$questions.length)',
                );
                return SaveProceedButton(
                  onTap: canSave
                      ? () {
                          debugPrint('💾 QuizView: Save button tapped');
                          controller.saveQuiz();
                        }
                      : null,
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(int totalQuestions) {
    return Container(
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
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Questions',
                      style: AppTextStyles.headline2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final answered = controller.selectedQuizAnswers.length;
                      return Text(
                        '$answered of $totalQuestions answered',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final answered = controller.selectedQuizAnswers.length;
            final progress = totalQuestions > 0
                ? answered / totalQuestions
                : 0.0;
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestion(
    String questionId,
    int questionNumber,
    int totalQuestions,
    String question,
    List<String> options,
  ) {
    return Obx(() {
      final isAnswered = controller.getSelectedAnswer(questionId) != null;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAnswered
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.primaryLighter,
            width: isAnswered ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isAnswered
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.04),
              blurRadius: isAnswered ? 12 : 8,
              offset: const Offset(0, 4),
              spreadRadius: isAnswered ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAnswered
                      ? [
                          AppColors.primary.withValues(alpha: 0.12),
                          AppColors.accentBlue.withValues(alpha: 0.08),
                        ]
                      : [
                          AppColors.primary.withValues(alpha: 0.06),
                          AppColors.accentBlue.withValues(alpha: 0.04),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accentBlue],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$questionNumber',
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (isAnswered)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildOptionsGrid(questionId, options),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOptionsGrid(String questionId, List<String> options) {
    return Column(
      children: List.generate(
        options.length,
        (index) =>
            _buildOption(questionId, options[index], index, options.length),
      ),
    );
  }

  Widget _buildOption(
    String questionId,
    String option,
    int index,
    int totalOptions,
  ) {
    return Obx(() {
      final isSelected = controller.getSelectedAnswer(questionId) == index;
      final isLast = index == totalOptions - 1;
      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              debugPrint('✅ QuizView: Option $index selected for $questionId');
              controller.selectQuizAnswer(questionId, index);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.accentBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [AppColors.surface, AppColors.surfaceVariant],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTextStyles.body1.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
