import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';

class TabBarWidget extends StatelessWidget {
  final RxInt selectedTab;
  final List<String> tabs;
  final List<IconData>? icons;
  final Function(int) onTabChanged;
  final Color? badgeColor;
  final Color? badgeBorderColor;
  final List<bool>? enabledTabs;

  const TabBarWidget({
    super.key,
    required this.selectedTab,
    required this.tabs,
    this.icons,
    required this.onTabChanged,
    this.badgeColor,
    this.badgeBorderColor,
    this.enabledTabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(
                () => AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: tabWidth * selectedTab.value + 4,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: tabWidth - 8,
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: badgeBorderColor != null
                          ? Border.all(color: badgeBorderColor!, width: 1.5)
                          : null,
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  tabs.length,
                  (index) => Expanded(child: _buildTab(tabs[index], index)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    return Obx(() {
      final isSelected = selectedTab.value == index;
      final isEnabled =
          enabledTabs == null ||
          enabledTabs!.length <= index ||
          enabledTabs![index];
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  debugPrint(
                    '🔄 TabBarWidget: Tab $index tapped (${tabs[index]})',
                  );
                  onTabChanged(index);
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icons != null && icons!.length > index) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isEnabled ? icons![index] : Icons.lock_outline_rounded,
                        key: ValueKey('icon_${index}_$isSelected$isEnabled'),
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : isEnabled
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (isSelected && label.toLowerCase() == 'live')
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: AppTextStyles.body2.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isEnabled
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.4),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                    child: Text(
                      label.toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
