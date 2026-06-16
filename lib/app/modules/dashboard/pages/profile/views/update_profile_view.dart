import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/modules/dashboard/pages/profile/controllers/update_profile_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  const UpdateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Profile'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Obx(() {
                final user = controller.currentUser;
                final userData = controller.userData;
                final photoURL = userData?.photoURL ?? user?.photoURL ?? '';
                final hasPhoto = photoURL.isNotEmpty;
                final displayName = user?.displayName ?? userData?.displayName ?? user?.email ?? userData?.email;
                final initial = displayName != null && displayName.isNotEmpty ? displayName[0].toUpperCase() : null;

                return Stack(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2.5),
                      ),
                      child: hasPhoto
                          ? ClipOval(
                              child: Image.network(
                                photoURL,
                                width: 100, height: 100, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Center(
                                  child: initial != null
                                      ? Text(initial, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary))
                                      : Icon(Icons.person, size: 48, color: AppColors.primary),
                                ),
                              ),
                            )
                          : Center(
                              child: initial != null
                                  ? Text(initial, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary))
                                  : Icon(Icons.person, size: 48, color: AppColors.primary),
                            ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),
              Text(
                controller.currentUser?.email ?? 'james@example.com',
                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Form Card - white container matching design #11
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(label: 'Full Name', controller: controller.nameController, hintText: 'Enter your full name'),
                    const SizedBox(height: 20),
                    _buildTextField(label: 'Phone Number', controller: controller.numberController, hintText: 'Enter your phone number', keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                    )
                  : Text('Update Profile', style: AppTextStyles.button.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, required TextEditingController controller,
    required String hintText, TextInputType? keyboardType, bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          enableInteractiveSelection: true,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: AppTextStyles.body1.copyWith(color: enabled ? AppColors.textPrimary : AppColors.textSecondary),
        ),
      ],
    );
  }
}
