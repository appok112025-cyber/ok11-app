import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';
import 'package:ok11/app/modules/dashboard/pages/ar/controllers/ar_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/widgets/common/tab_bar_widget.dart';

class ArView extends GetView<ArController> {
  const ArView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56,
        title: const Text('AR Arena', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBarWidget(
              selectedTab: controller.selectedIndex,
              tabs: const ['Players', 'Live Matches', 'Past Matches'],
              onTabChanged: (index) => controller.onTabChanged(index),
            ),
            Expanded(
              child: Obx(() {
                final selected = controller.selectedIndex.value;
                switch (selected) {
                  case 0:
                    return _buildArTabContent(context,
                      title: 'AR Player View',
                      imagePath: 'assets/images/Players.jpeg',
                      description: 'Visualize live squad lineups and player performance statistics mapped onto physical surfaces.',
                    );
                  case 1:
                    return _buildArTabContent(context,
                      title: 'AR Live Matches View',
                      imagePath: 'assets/images/Live_Matches.jpeg',
                      description: 'Project live action cricket fields onto your coffee table with real-time positional player feeds.',
                    );
                  case 2:
                    return _buildArTabContent(context,
                      title: 'AR Past Matches View',
                      imagePath: 'assets/images/Past_Matches.jpeg',
                      description: 'Replay match milestones, and critical gameplay strategies in full 3D simulation.',
                    );
                  default:
                    return _buildArTabContent(context,
                      title: 'AR Player View',
                      imagePath: 'assets/images/Players.jpeg',
                      description: 'Visualize live squad lineups and player performance statistics mapped onto physical surfaces.',
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArTabContent(BuildContext context, {
    required String title, required String imagePath, required String description,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description card - matches designs #13, 14, 15
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              description,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main AR Showcase Card
          GestureDetector(
            onTap: () => controller.showPremiumDialog(context, title),
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 2)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(imagePath, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: AppColors.surfaceVariant,
                        child: Center(child: Icon(UniconsLine.image_broken, size: 48, color: Colors.redAccent)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.65)],
                        ),
                      ),
                    ),
                    // ★ PREMIUM badge - yellow/orange rounded (matches designs)
                    Positioned(
                      top: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                    // Yellow play button circle
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                          border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.6), width: 2.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFB800)),
                          child: Icon(Icons.play_arrow, size: 32, color: Colors.white),
                        ),
                      ),
                    ),
                    // Title and subtitle at bottom
                    Positioned(
                      bottom: 24, left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(UniconsLine.qrcode_scan, size: 14, color: Color(0xFFFFB800)),
                              const SizedBox(width: 4),
                              Text('Scan to see detailed stats & 360° view',
                                style: TextStyle(color: const Color(0xFFFFB800).withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
