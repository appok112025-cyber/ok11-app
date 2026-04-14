import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:ok11/app/modules/dashboard/pages/profile/controllers/profile_controller.dart';
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
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.toNamed(Routes.UPDATE_PROFILE);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.getGradientWithAlpha(
                        AppColors.teamGradient,
                        0.15,
                      ),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Obx(() {
                        final userData = controller.userData;
                        final photoURL =
                            userData?.photoURL ?? user?.photoURL ?? '';
                        final hasPhoto = photoURL.isNotEmpty;
                        return Stack(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: !hasPhoto
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.accentPink.withValues(
                                            alpha: 0.2,
                                          ),
                                          AppColors.accentPurple.withValues(
                                            alpha: 0.15,
                                          ),
                                        ],
                                      )
                                    : null,
                                color: hasPhoto ? Colors.transparent : null,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accentPink.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 2.5,
                                ),
                              ),
                              child: hasPhoto
                                  ? ClipOval(
                                      child: Image.network(
                                        photoURL,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return _buildAvatarFallback(
                                                user,
                                                userData,
                                              );
                                            },
                                      ),
                                    )
                                  : _buildAvatarFallback(user, userData),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              final userData = controller.userData;
                              final displayName =
                                  user?.displayName ??
                                  userData?.displayName ??
                                  user?.email ??
                                  userData?.email ??
                                  'User';
                              return Text(
                                displayName,
                                style: AppTextStyles.headline2,
                              );
                            }),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Obx(() {
                                  final userData = controller.userData;
                                  final hasEmail =
                                      user?.email != null ||
                                      (userData?.email != null &&
                                          userData!.email.isNotEmpty);
                                  return Icon(
                                    hasEmail
                                        ? Icons.email_outlined
                                        : Icons.phone_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  );
                                }),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Obx(() {
                                    final userData = controller.userData;
                                    final contactInfo =
                                        user?.email ??
                                        userData?.email ??
                                        user?.phoneNumber ??
                                        'No contact info';
                                    return Text(
                                      contactInfo,
                                      style: AppTextStyles.body2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Information'),
            const SizedBox(height: 12),

            _menuTile(
              Icons.star_outline,
              'Skill Based Point System',
              'Earn points based on skill',
              () {
                Get.toNamed(Routes.POINTS);
              },
            ),
            const SizedBox(height: 8),
            _menuTile(
              Icons.description_outlined,
              'Terms & Conditions',
              'Read our terms',
              () {
                Get.toNamed(Routes.TERMS);
              },
            ),
            const SizedBox(height: 8),
            _menuTile(Icons.info_outline, 'About', 'Learn more about OK11', () {
              Get.toNamed(Routes.ABOUT);
            }),
            const SizedBox(height: 8),
            _menuTile(
              Icons.help_outline,
              'FAQ',
              'Frequently asked questions',
              () {
                Get.toNamed(Routes.FAQ);
              },
            ),
            const SizedBox(height: 24),
            _menuTile(
              Icons.logout,
              'Logout',
              'Sign out from your account',
              () => controller.logout(),
              isDestructive: true,
            ),
            const SizedBox(height: 24),
            Obx(
              () => Center(
                child: Text(
                  controller.appVersion,
                  style: AppTextStyles.caption,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(
    firebase_auth.User? user,
    auth_store.User? userData,
  ) {
    final displayName =
        user?.displayName ??
        userData?.displayName ??
        user?.email ??
        userData?.email;
    final initial = displayName != null && displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : null;

    return Center(
      child: initial != null
          ? Text(
              initial,
              style: AppTextStyles.headline1.copyWith(
                fontSize: 24,
                color: AppColors.primary,
              ),
            )
          : Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _menuTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLighter, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDestructive ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body1.copyWith(
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.body2),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
