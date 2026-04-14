import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/my_matches/controllers/my_matches_controller.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/widgets/common/match_card_widget.dart';
import 'package:ok11/app/widgets/common/shimmer_widget.dart';
import 'package:ok11/app/widgets/common/tab_bar_widget.dart';

class MyMatchesView extends GetView<MyMatchesController> {
  const MyMatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Matches'), centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final selectedIndex = controller.selectedTab.value;
              final status = _getStatusFromTabIndex(selectedIndex);
              return AbsorbPointer(
                absorbing: controller.isLoading.value,
                child: TabBarWidget(
                  selectedTab: controller.selectedTab,
                  tabs: const ['upcoming', 'Live', 'completed'],
                  onTabChanged: (index) => controller.onTabChanged(index),
                  badgeColor: StatusTheme.getBadgeColor(status),
                  badgeBorderColor: StatusTheme.getBadgeBorderColor(status),
                ),
              );
            }),
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: () async {
                    debugPrint('🔄 MyMatchesView: Pull to refresh triggered');
                    await controller.refreshMatches();
                  },
                  color: AppColors.primary,
                  child: controller.isLoading.value
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: 3,
                          itemBuilder: (context, index) =>
                              const ShimmerMatchCard(),
                        )
                      : controller.currentMatches.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 250,
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
                                        Icons.sports_soccer_outlined,
                                        size: 56,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'No Matches Yet',
                                      style: AppTextStyles.headline2.copyWith(
                                        color: AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Join contests to see your matches here',
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
                      : AbsorbPointer(
                          absorbing: controller.isLoading.value,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.currentMatches.length,
                            itemBuilder: (context, index) {
                              final match = controller.currentMatches[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: MatchCardWidget(
                                  match: match,
                                  isLoading: controller.isLoading.value,
                                  showScoreCard: true,
                                  onTap: () {
                                    if (match.status == MatchStatus.upcoming) {
                                      Get.toNamed(
                                        Routes.MATCH_DETAIL,
                                        arguments: match,
                                      );
                                    } else if (match.status ==
                                        MatchStatus.live) {
                                      Get.toNamed(
                                        Routes.MATCH_DETAIL,
                                        arguments: match,
                                      );
                                    } else if (match.status ==
                                        MatchStatus.completed) {
                                      Get.toNamed(
                                        Routes.MATCH_DETAIL,
                                        arguments: match,
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MatchStatus _getStatusFromTabIndex(int index) {
    switch (index) {
      case 0:
        return MatchStatus.upcoming;
      case 1:
        return MatchStatus.live;
      case 2:
        return MatchStatus.completed;
      default:
        return MatchStatus.upcoming;
    }
  }
}
