import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/modules/dashboard/pages/profile/controllers/terms_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/html_utils.dart';
import 'package:ok11/app/widgets/common/site_content_shimmer.dart';

class TermsView extends GetView<TermsController> {
  const TermsView({super.key});

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
        title: const Text('Terms & Conditions'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                              AppColors.primaryGradient,
                              0.15,
                            ),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
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
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.description,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Terms & Conditions',
                                style: AppTextStyles.headline1.copyWith(
                                  fontSize: 24,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.termsContent.value?.content != null) ...[
                        (() {
                          final stripped = HtmlUtils.stripHtmlTags(controller.termsContent.value!.content!);
                          if (stripped.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primaryLighter,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  stripped,
                                  style: AppTextStyles.body1.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          );
                        })(),
                      ],
                      if (controller.termsContent.value?.items != null &&
                          controller.termsContent.value!.items.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        ...controller.termsContent.value!.items
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
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index <
                                          controller.termsContent.value!.items
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
                                child: _buildTermItem(
                                  _getTermIcon(index),
                                  item.title,
                                  item.description,
                                ),
                              );
                            }),
                      ] else if (controller.termsContent.value != null &&
                          (controller.termsContent.value!.content == null ||
                              controller
                                  .termsContent
                                  .value!
                                  .content!
                                  .isEmpty) &&
                          (controller.termsContent.value!.items.isEmpty)) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.description,
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

  IconData _getTermIcon(int index) {
    final icons = [
      Icons.shield,
      Icons.receipt_long,
      Icons.science,
      Icons.shield,
      Icons.lock,
      Icons.gavel,
      Icons.vpn_key,
      Icons.add_box,
    ];
    return icons[index % icons.length];
  }

  Widget _buildTermItem(IconData icon, String title, String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
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
