import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/pages/ar/controllers/ar_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';

class ArView extends GetView<ArController> {
  const ArView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 70,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAE19).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  color: Color(0xFFE5A93B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AR Arena',
                    style: AppTextStyles.headline2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFE5A93B),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PREMIUM SUITE',
                        style: TextStyle(
                          color: const Color(0xFFE5A93B),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            onTap: controller.onTabChanged,
            indicatorColor: const Color(0xFFE5A93B),
            labelColor: const Color(0xFFE5A93B),
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            dividerColor: Colors.black12,
            tabs: const [
              Tab(text: 'Players'),
              Tab(text: 'Live Matches'),
              Tab(text: 'Past Matches'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildArTabContent(
                context,
                title: 'AR Players View',
                imagePath: 'assets/images/Players.jpeg',
                description: 'Visualize live squad lineups and player performance statistics mapped onto physical surfaces.',
              ),
              _buildArTabContent(
                context,
                title: 'AR Live Matches',
                imagePath: 'assets/images/Live_Matches.jpeg',
                description: 'Project live action soccer fields onto your coffee table with real-time positional player feeds.',
              ),
              _buildArTabContent(
                context,
                title: 'AR Past Matches Replay',
                imagePath: 'assets/images/Past_Matches.jpeg',
                description: 'Replay match milestones, goal arcs, and critical gameplay strategies in full 3D simulation.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArTabContent(
    BuildContext context, {
    required String title,
    required String imagePath,
    required String description,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFE5A93B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Interactive AR Showcase Card
          GestureDetector(
            onTap: () => controller.showPremiumDialog(context, title),
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Main JPEG Image
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),

                    // Translucent dark gradient overlay for visual premium depth
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),

                    // Gold Crown floating badge on top right
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF11141B).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE5A93B),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFAE19),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Color(0xFFFFAE19),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlay content (Title and Central CTA)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFAE19).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFFFAE19).withValues(alpha: 0.6),
                            width: 2.0,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFAE19),
                          ),
                          child: const Icon(
                            Icons.videocam_outlined,
                            color: Color(0xFF11141B),
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    // Title and tap prompt at the bottom
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                color: const Color(0xFFFFAE19).withValues(alpha: 0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to Launch AR Experience',
                                style: TextStyle(
                                  color: const Color(0xFFFFAE19).withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
