import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/theme/app_colors.dart';

class TabBarWidget extends StatelessWidget {
  final RxInt selectedTab;
  final List<String> tabs;
  final List<dynamic>? icons;
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
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(
                () => AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  left: tabWidth * selectedTab.value + 2,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    width: tabWidth - 4,
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: badgeBorderColor != null
                          ? Border.all(color: badgeBorderColor!, width: 1.2)
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
                      child: Icon(isEnabled ? (icons![index] as IconData) : Icons.lock,
                        key: ValueKey('icon_${index}_$isSelected$isEnabled'),
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : isEnabled
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
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
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isEnabled
                              ? const Color(0xFF374151)
                              : const Color(0xFF9CA3AF),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 14.5,
                          letterSpacing: 0.2,
                        ),
                        child: Text(
                          label[0].toUpperCase() + label.substring(1),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    });
  }
}
