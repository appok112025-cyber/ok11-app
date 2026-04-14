import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/points_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/html_utils.dart';
import 'package:ok11/app/widgets/common/site_content_shimmer.dart';

class PointsView extends GetView<PointsController> {
  const PointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Skill Based Point System'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const PointsShimmer()
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
                              AppColors.successGradient,
                              0.15,
                            ),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentGreen.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGreen.withValues(
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
                                    AppColors.accentGreen,
                                    AppColors.accentTeal,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Skill Based Point System',
                                style: AppTextStyles.headline1.copyWith(
                                  fontSize: 24,
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.pointsContent.value?.content != null &&
                          controller
                              .pointsContent
                              .value!
                              .content!
                              .isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accentGreen.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            HtmlUtils.stripHtmlTags(
                              controller.pointsContent.value!.content!,
                            ),
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                      if (controller.pointsContent.value?.items != null &&
                          controller.pointsContent.value!.items.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        ...controller.pointsContent.value!.items
                            .where(
                              (item) =>
                                  item.title.isNotEmpty &&
                                  item.description.isNotEmpty,
                            )
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final colors = [
                                AppColors.accentYellow,
                                AppColors.accentBlue,
                                AppColors.accentGreen,
                                AppColors.accentPurple,
                                AppColors.accentOrange,
                                AppColors.accentPink,
                              ];
                              final icons = [
                                Icons.emoji_events_rounded,
                                Icons.trending_up_rounded,
                                Icons.verified_rounded,
                                Icons.star_rounded,
                                Icons.thumb_up_rounded,
                                Icons.bolt_rounded,
                              ];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index <
                                          controller.pointsContent.value!.items
                                                  .where(
                                                    (i) =>
                                                        i.title.isNotEmpty &&
                                                        i
                                                            .description
                                                            .isNotEmpty,
                                                  )
                                                  .length -
                                              1
                                      ? 16
                                      : 0,
                                ),
                                child: _buildPointItem(
                                  icons[index % icons.length],
                                  item.title,
                                  item.description,
                                  colors[index % colors.length],
                                ),
                              );
                            }),
                      ] else if (controller.pointsContent.value != null &&
                          (controller.pointsContent.value!.content == null ||
                              controller
                                  .pointsContent
                                  .value!
                                  .content!
                                  .isEmpty) &&
                          (controller.pointsContent.value!.items.isEmpty)) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.star_outline_rounded,
                                size: 48,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No content available',
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPointItem(
    IconData icon,
    String title,
    String text,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.2),
                  accentColor.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
