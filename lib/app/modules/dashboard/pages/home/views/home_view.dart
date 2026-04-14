import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/home/controllers/home_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/assets.dart';
import 'package:ok11/app/widgets/common/match_card_widget.dart';
import 'package:ok11/app/widgets/common/shimmer_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        title: Row(
          children: [
            Image.asset(
              Assets.logo,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text('OK11', style: AppTextStyles.headline2),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: () async {
              debugPrint('🔄 HomeView: Pull to refresh triggered');
              await controller.refreshMatches();
            },
            color: AppColors.primary,
            child: controller.isLoading.value
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (context, index) => const ShimmerMatchCard(),
                  )
                : !controller.hasMatches
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.sports_cricket_outlined,
                                  size: 56,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Stay Tuned',
                                style: AppTextStyles.headline2.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Exciting matches are coming soon!',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.matches.length,
                    itemBuilder: (context, index) {
                      final match = controller.matches[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MatchCardWidget(
                          match: match,
                          isLoading: controller.isLoading.value,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
