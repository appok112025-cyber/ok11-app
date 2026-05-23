import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/theme/app_colors.dart';

class ArController extends GetxController {
  final selectedIndex = 0.obs;

  void onTabChanged(int index) {
    debugPrint('🔄 ArController: Selected tab $index');
    selectedIndex.value = index;
  }

  void showPremiumDialog(BuildContext context, String featureName) {
    debugPrint('🔔 ArController: Showing premium dialog for $featureName');
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: Color(0xFFE5A93B), // Premium Gold Border
              width: 2.0,
            ),
          ),
          backgroundColor: const Color(0xFF11141B), // Luxurious Dark Background
          surfaceTintColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  const Color(0xFF251F14), // Subtle gold glow at top
                  const Color(0xFF11141B), // Solid dark bottom
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown Icon with glow effect
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5A93B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5A93B).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 50,
                    color: Color(0xFFFFAE19), // Vivid premium golden
                  ),
                ),
                const SizedBox(height: 24),
                
                // Premium Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFAE19), Color(0xFFE5A93B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PREMIUM FEATURE',
                    style: TextStyle(
                      color: Color(0xFF11141B),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  featureName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Status - Coming Soon
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: const Color(0xFFFFAE19).withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Explanation text
                const Text(
                  'Experience our elite AR engine! Get ready to visualize match fields, player analytics, and past replay data in standard-setting augmented reality.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFA0A5B5),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Close button with golden styling
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF11141B),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFAE19), Color(0xFFE5A93B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5A93B).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'GOT IT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
