import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/about_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/assets.dart';
import 'package:ok11/app/utils/html_utils.dart';
import 'package:ok11/app/widgets/common/site_content_shimmer.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

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
        title: const Text('About'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.getGradientWithAlpha(
                              AppColors.teamGradient,
                              0.15,
                            ),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.accentBlue.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                Assets.logo,
                                width: 80,
                                height: 80,
                              ),
                            ),
                            if (controller.aboutContent.value?.content != null) ...[
                              (() {
                                final stripped = HtmlUtils.stripHtmlTags(controller.aboutContent.value!.content!);
                                if (stripped.isEmpty) return const SizedBox.shrink();
                                return Column(
                                  children: [
                                    const SizedBox(height: 24),
                                    Text(
                                      stripped,
                                      style: AppTextStyles.body1.copyWith(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        height: 1.6,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                );
                              })(),
                            ],
                          ],
                        ),
                      ),
                      if (controller.aboutContent.value?.links != null &&
                          controller.aboutContent.value!.links.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Follow for more',
                          style: AppTextStyles.headline2.copyWith(
                            fontSize: 20,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...controller.aboutContent.value!.links
                            .asMap()
                            .entries
                            .map((entry) {
                              final index = entry.key;
                              final link = entry.value;
                              if (link.title.isEmpty || link.url.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final colors = [
                                AppColors.accentPink,
                                AppColors.accentBlue,
                                AppColors.accentGreen,
                                AppColors.accentPurple,
                                AppColors.accentOrange,
                              ];
                              final icons = [
                                Icons.camera_alt,
                                UniconsLine.estate,
                                UniconsLine.link,
                                Icons.public,
                                Icons.share,
                              ];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index <
                                          controller
                                                  .aboutContent
                                                  .value!
                                                  .links
                                                  .length -
                                              1
                                      ? 12
                                      : 0,
                                ),
                                child: _buildSocialLink(
                                  link.title,
                                  link.url,
                                  icons[index % icons.length],
                                  colors[index % colors.length],
                                ),
                              );
                            }),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite,
                                color: AppColors.accentPink,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Follow for more updates',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (controller.aboutContent.value != null &&
                          (controller.aboutContent.value!.content == null ||
                              controller
                                  .aboutContent
                                  .value!
                                  .content!
                                  .isEmpty)) ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.info,
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

  Widget _buildSocialLink(
    String platform,
    String url,
    IconData icon,
    Color accentColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          try {
            final uri = Uri.parse(url);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint('❌ Failed to open URL: $url - Error: $e');
            Get.snackbar(
              'Error',
              'Could not open link',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
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
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
