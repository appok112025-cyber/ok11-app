import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/modules/auth/login/controllers/login_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/utils/assets.dart';
import 'package:ok11/app/widgets/common/google_sign_in_button.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, AppColors.primary.withValues(alpha: 0.02)],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              final clampedValue = value.clamp(0.0, 1.0);
                              return Transform.scale(
                                scale: clampedValue,
                                child: Opacity(
                                  opacity: clampedValue,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      Assets.logo,
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              final clampedValue = value.clamp(0.0, 1.0);
                              final delayedValue = clampedValue < 0.3
                                  ? 0.0
                                  : ((clampedValue - 0.3) / 0.7).clamp(
                                      0.0,
                                      1.0,
                                    );
                              return Opacity(
                                opacity: delayedValue,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - delayedValue)),
                                  child: Column(
                                    children: [
                                      Text(
                                        'OK11',
                                        style: AppTextStyles.headline1.copyWith(
                                          color: AppColors.primary,
                                          fontSize: 40,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Fan engagement app',
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 80),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              final clampedValue = value.clamp(0.0, 1.0);
                              final delayedValue = clampedValue < 0.4
                                  ? 0.0
                                  : ((clampedValue - 0.4) / 0.6).clamp(
                                      0.0,
                                      1.0,
                                    );
                              return Opacity(
                                opacity: delayedValue,
                                child: Transform.translate(
                                  offset: Offset(0, 15 * (1 - delayedValue)),
                                  child: Obx(
                                    () => AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: GoogleSignInButton(
                                        key: ValueKey(
                                          controller.isGoogleLoading.value,
                                        ),
                                        onPressed: controller.signInWithGoogle,
                                        isLoading:
                                            controller.isGoogleLoading.value,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Obx(
                            () => AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: controller.errorMessage.value.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: _buildErrorMessage(
                                        controller.errorMessage.value,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
