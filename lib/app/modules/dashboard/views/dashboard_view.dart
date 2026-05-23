import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ok11/app/modules/dashboard/pages/home/views/home_view.dart';
import 'package:ok11/app/modules/dashboard/pages/profile/views/profile_view.dart';
import 'package:ok11/app/modules/dashboard/pages/my_matches/views/my_matches_view.dart';
import 'package:ok11/app/modules/dashboard/pages/ar/views/ar_view.dart';
import 'package:ok11/app/theme/app_colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => _buildPage(controller.currentIndex.value)),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: controller.currentIndex.value,
              onTap: controller.onTabTapped,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              elevation: 0,
              selectedIconTheme: IconThemeData(
                size: 26,
                color: AppColors.primary,
              ),
              unselectedIconTheme: IconThemeData(
                size: 24,
                color: AppColors.textSecondary,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_soccer_outlined),
                  activeIcon: Icon(Icons.sports_soccer_rounded),
                  label: 'My Matches',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.view_in_ar_outlined),
                  activeIcon: Icon(Icons.view_in_ar_rounded),
                  label: 'AR',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const MyMatchesView();
      case 2:
        return const ArView();
      case 3:
        return const ProfileView();
      default:
        return const HomeView();
    }
  }
}
