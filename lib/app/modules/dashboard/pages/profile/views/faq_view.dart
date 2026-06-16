import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/modules/dashboard/pages/profile/controllers/faq_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/widgets/common/site_content_shimmer.dart';

class FaqView extends GetView<FaqController> {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text('FAQ'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : controller.faqs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No FAQs available',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.getGradientWithAlpha(
                              AppColors.warningGradient,
                              0.15,
                            ),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentYellow.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentYellow.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accentYellow,
                                    AppColors.accentOrange,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.help,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Frequently Asked Questions',
                                style: AppTextStyles.headline1.copyWith(
                                  fontSize: 22,
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...controller.faqs
                          .where(
                            (faq) =>
                                faq.question.isNotEmpty &&
                                faq.answer.isNotEmpty,
                          )
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final faq = entry.value;
                            final colors = [
                              AppColors.accentBlue,
                              AppColors.accentGreen,
                              AppColors.accentPurple,
                              AppColors.accentPink,
                              AppColors.accentOrange,
                              AppColors.accentYellow,
                            ];
                            final icons = [
                              Icons.play_arrow,
                              Icons.receipt_long,
                              Icons.military_tech,
                              Icons.help,
                              Icons.info,
                              Icons.help,
                            ];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    index <
                                        controller.faqs
                                                .where(
                                                  (f) =>
                                                      f.question.isNotEmpty &&
                                                      f.answer.isNotEmpty,
                                                )
                                                .length -
                                            1
                                    ? 16
                                    : 0,
                              ),
                              child: _buildQASection(
                                icons[index % icons.length],
                                faq.question,
                                faq.answer,
                                colors[index % colors.length],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQASection(
    IconData icon,
    String question,
    String answer,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: AppTextStyles.headline2.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              answer,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
