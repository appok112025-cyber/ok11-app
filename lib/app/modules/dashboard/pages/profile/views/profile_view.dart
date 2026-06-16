import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/profile_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ok11/app/routes/app_pages.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/stores/auth_store.dart' as auth_store;

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Card - Purple gradient (design #12)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.UPDATE_PROFILE),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Obx(() {
                        final userData = controller.userData;
                        final photoURL = userData?.photoURL ?? user?.photoURL ?? '';
                        final hasPhoto = photoURL.isNotEmpty;
                        return Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: hasPhoto
                                  ? ClipOval(
                                      child: Image.network(
                                        photoURL,
                                        width: 60, height: 60, fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => _buildAvatarFallback(user, userData, isWhite: true),
                                      ),
                                    )
                                  : _buildAvatarFallback(user, userData, isWhite: true),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                ),
                                child: Center(
                                  child: Icon(Icons.edit, size: 11, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              final userData = controller.userData;
                              final displayName = user?.displayName ?? userData?.displayName ?? user?.email ?? userData?.email ?? 'User';
                              return Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700));
                            }),
                            const SizedBox(height: 4),
                            Obx(() {
                              final userData = controller.userData;
                              final contactInfo = user?.email ?? userData?.email ?? user?.phoneNumber ?? 'No contact info';
                              return Text(
                                contactInfo,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 28, color: Colors.white.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ACCOUNT & INFO label - exactly matches design
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'ACCOUNT & INFO',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700, letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Menu items with Iconify icons - matching design #12 exactly
            _menuTile(
              Icons.share, 'Share', 'Share with your friends', () {
                Share.share('Check out the OK11 App: https://play.google.com/store/apps/details?id=com.ok11.app');
              },
              iconBgColor: AppColors.primary, iconColor: Colors.white,
            ),
            const SizedBox(height: 8),
            _menuTile(
              Icons.grid_view, 'Skill Based Point System', 'How points are calculated',
              () => Get.toNamed(Routes.POINTS),
              iconBgColor: AppColors.primary, iconColor: Colors.white,
            ),
            const SizedBox(height: 8),
            _menuTile(
              Icons.description, 'Terms & Conditions', 'Rules and regulations',
              () => Get.toNamed(Routes.TERMS),
              iconBgColor: AppColors.primary, iconColor: Colors.white,
            ),
            const SizedBox(height: 8),
            _menuTile(
              Icons.info, 'About', 'Version 2.4.0',
              () => Get.toNamed(Routes.ABOUT),
              iconBgColor: AppColors.primary, iconColor: Colors.white,
            ),
            const SizedBox(height: 8),
            _menuTile(
              Icons.help, 'FAQ', 'Help and support',
              () => Get.toNamed(Routes.FAQ),
              iconBgColor: AppColors.primary, iconColor: Colors.white,
            ),
            const SizedBox(height: 16),
            // Logout
            _menuTile(
              Icons.logout, 'Logout', 'Exit the application',
              () => controller.logout(),
              isDestructive: true,
              iconBgColor: const Color(0xFFFDF2F2), iconColor: const Color(0xFF9B1C1C),
            ),
            const SizedBox(height: 24),
            Obx(() => Center(child: Text(controller.appVersion, style: AppTextStyles.caption))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(firebase_auth.User? user, auth_store.User? userData, {bool isWhite = false}) {
    final displayName = user?.displayName ?? userData?.displayName ?? user?.email ?? userData?.email;
    final initial = displayName != null && displayName.isNotEmpty ? displayName[0].toUpperCase() : null;
    return Center(
      child: initial != null
          ? Text(initial, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: isWhite ? Colors.white : AppColors.primary))
          : Icon(Icons.person, size: 32, color: isWhite ? Colors.white : AppColors.primary),
    );
  }

  Widget _menuTile(IconData icon, String title, String subtitle, VoidCallback? onTap, {
    bool isDestructive = false, Color? iconBgColor, Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor ?? AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body1.copyWith(
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                      fontWeight: FontWeight.w600, fontSize: 15,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.body2.copyWith(
                      fontSize: 12,
                      color: isDestructive ? AppColors.error.withValues(alpha: 0.7) : AppColors.textSecondary,
                    )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 24, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
