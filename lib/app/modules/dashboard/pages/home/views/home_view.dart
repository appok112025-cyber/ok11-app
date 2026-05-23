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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => Text(
                                '₹${controller.walletBalance.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F1923),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => controller.withdraw(1000),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'WITHDRAW',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.grey.shade700,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'CLOSE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Text(
                        '₹${controller.walletBalance.value.toInt()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F1923),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
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
