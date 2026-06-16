import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ok11/app/modules/dashboard/pages/profile/controllers/points_controller.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';
import 'package:ok11/app/widgets/common/tab_bar_widget.dart';

class PointsView extends GetView<PointsController> {
  const PointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text('Skill Based Point System'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBarWidget(
            selectedTab: controller.selectedTab,
            tabs: const ['T20', 'ODI', 'TEST'],
            onTabChanged: (index) {
              controller.selectedTab.value = index;
            },
          ),
          Expanded(
            child: Obx(() {
              final selected = controller.selectedTab.value;
              switch (selected) {
                case 0:
                  return _buildPointsList(context, 'T20');
                case 1:
                  return _buildPointsList(context, 'ODI');
                case 2:
                  return _buildPointsList(context, 'TEST');
                default:
                  return _buildPointsList(context, 'T20');
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList(BuildContext context, String matchType) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // Top Banner card showing format context
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$matchType Rules & Points',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Points calculations optimized for $matchType contests.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 1. General Points
        _buildSection(
          title: 'General Points',
          icon: Icons.star,
          accentColor: AppColors.accentBlue,
          rows: _getGeneralPoints(matchType),
        ),
        const SizedBox(height: 16),

        // 2. Batting Points
        _buildSection(
          title: 'Batting Points',
          icon: Icons.play_arrow,
          accentColor: AppColors.accentGreen,
          rows: _getBattingPoints(matchType),
        ),
        const SizedBox(height: 16),

        // 3. Bowling Points
        _buildSection(
          title: 'Bowling Points',
          icon: Icons.favorite,
          accentColor: AppColors.accentYellow,
          rows: _getBowlingPoints(matchType),
        ),
        const SizedBox(height: 16),

        // 4. Fielding Points
        _buildSection(
          title: 'Fielding Points',
          icon: Icons.military_tech,
          accentColor: AppColors.accentPink,
          rows: _getFieldingPoints(matchType),
        ),
        const SizedBox(height: 16),

        // 5. Other Points
        _buildSection(
          title: 'Other Points',
          icon: Icons.more_horiz,
          accentColor: AppColors.accentPurple,
          rows: _getOtherPoints(matchType),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<PointRow> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor.withValues(alpha: 0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
            itemBuilder: (context, index) {
              final row = rows[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.action,
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (row.description != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              row.description!,
                              style: AppTextStyles.body2.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: row.value.startsWith('-')
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        row.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: row.value.startsWith('-') ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // General Points generator
  List<PointRow> _getGeneralPoints(String matchType) {
    if (matchType == 'T20') {
      return [
        PointRow(action: 'Wicket', value: '+ 30 pts'),
        PointRow(action: 'Run', value: '+ 1 pts'),
        PointRow(action: 'Dot Ball', value: '+ 1 pts'),
      ];
    } else if (matchType == 'ODI') {
      return [
        PointRow(action: 'Wicket', value: '+ 30 pts'),
        PointRow(action: 'Run', value: '+ 1 pts'),
        PointRow(action: 'Dot Ball', value: '+ 1 pts'),
      ];
    } else {
      // TEST
      return [
        PointRow(action: 'Wicket', value: '+ 30 pts'),
        PointRow(action: 'Run', value: '+ 1 pts'),
        PointRow(action: 'Catch', value: '+ 8 pts'),
      ];
    }
  }

  // Batting Points generator
  List<PointRow> _getBattingPoints(String matchType) {
    final list = [
      PointRow(action: 'Run', value: '+ 1 pts'),
      PointRow(action: 'Boundary Bonus', value: '+ 4 pts'),
      PointRow(action: 'Six Bonus', value: '+ 6 pts'),
      PointRow(action: '25 Run Bonus', value: '+ 4 pts'),
      PointRow(action: '50 Run Bonus', value: '+ 8 pts'),
      PointRow(action: '75 Run Bonus', value: '+ 12 pts'),
      PointRow(action: '100 Run Bonus', value: '+ 16 pts'),
    ];

    if (matchType == 'ODI' || matchType == 'TEST') {
      list.add(PointRow(action: '125 Run Bonus', value: '+ 20 pts'));
      list.add(PointRow(action: '150 Run Bonus', value: '+ 24 pts'));
    }

    if (matchType == 'T20') {
      list.add(PointRow(action: 'Dismissal for a Duck', value: '- 2 pts'));
      // Strike Rate Points
      list.addAll([
        PointRow(action: 'Strike Rate (Above 170)', value: '+ 6 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (150.01 - 170)', value: '+ 4 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (130 - 150)', value: '+ 2 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (60 - 70)', value: '- 2 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (50 - 59.99)', value: '- 4 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (Below 50)', value: '- 6 pts', description: 'runs per 100 balls (Except Bowlers)'),
      ]);
    } else if (matchType == 'ODI') {
      list.add(PointRow(action: 'Dismissal for a Duck', value: '- 3 pts'));
      list.addAll([
        PointRow(action: 'Strike Rate (Above 140)', value: '+ 6 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (120.01 - 140)', value: '+ 4 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (100 - 120)', value: '+ 2 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (40 - 50)', value: '- 2 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (30 - 39.99)', value: '- 4 pts', description: 'runs per 100 balls (Except Bowlers)'),
        PointRow(action: 'Strike Rate (Below 30)', value: '- 6 pts', description: 'runs per 100 balls (Except Bowlers)'),
      ]);
    } else {
      // TEST
      list.add(PointRow(action: 'Dismissal for a Duck', value: '- 4 pts'));
    }

    return list;
  }

  // Bowling Points generator
  List<PointRow> _getBowlingPoints(String matchType) {
    if (matchType == 'T20') {
      return [
        PointRow(action: 'Dot Ball', value: '+ 1 pts'),
        PointRow(action: 'Wicket (Excluding run out)', value: '+ 30 pts'),
        PointRow(action: 'Bonus (LBW/Bowled)', value: '+ 8 pts'),
        PointRow(action: '3 Wicket Bonus', value: '+ 4 pts'),
        PointRow(action: '4 Wicket Bonus', value: '+ 8 pts'),
        PointRow(action: '5 Wicket Bonus', value: '+ 12 pts'),
        PointRow(action: 'Maiden Over', value: '+ 8 pts'),
        PointRow(action: 'Economy Rate (Below 5)', value: '+ 6 pts', description: 'runs per over (min 2 overs)'),
        PointRow(action: 'Economy Rate (5 - 5.99)', value: '+ 4 pts', description: 'runs per over (min 2 overs)'),
        PointRow(action: 'Economy Rate (6 - 7)', value: '+ 2 pts', description: 'runs per over (min 2 overs)'),
        PointRow(action: 'Economy Rate (10 - 11)', value: '- 2 pts', description: 'runs per over (min 2 overs)'),
        PointRow(action: 'Economy Rate (11.01 - 12)', value: '- 4 pts', description: 'runs per over (min 2 overs)'),
        PointRow(action: 'Economy Rate (Above 12)', value: '- 6 pts', description: 'runs per over (min 2 overs)'),
      ];
    } else if (matchType == 'ODI') {
      return [
        PointRow(action: 'Dot ball (Every 3 dot balls)', value: '+ 1 pts'),
        PointRow(action: 'Wicket (Excluding run out)', value: '+ 30 pts'),
        PointRow(action: 'Bonus (LBW/Bowled)', value: '+ 8 pts'),
        PointRow(action: '3 Wicket Bonus', value: '+ 4 pts'),
        PointRow(action: '4 Wicket Bonus', value: '+ 8 pts'),
        PointRow(action: '5 Wicket Bonus', value: '+ 12 pts'),
        PointRow(action: 'Maiden Over', value: '+ 8 pts'),
        PointRow(action: 'Economy Rate (Below 2.5)', value: '+ 6 pts', description: 'runs per over (min 5 overs)'),
        PointRow(action: 'Economy Rate (2.5 - 3.49)', value: '+ 4 pts', description: 'runs per over (min 5 overs)'),
        PointRow(action: 'Economy Rate (3.5 - 4.5)', value: '+ 2 pts', description: 'runs per over (min 5 overs)'),
        PointRow(action: 'Economy Rate (7 - 8)', value: '- 2 pts', description: 'runs per over (min 5 overs)'),
        PointRow(action: 'Economy Rate (8.01 - 9)', value: '- 4 pts', description: 'runs per over (min 5 overs)'),
        PointRow(action: 'Economy Rate (Above 9)', value: '- 6 pts', description: 'runs per over (min 5 overs)'),
      ];
    } else {
      // TEST
      return [
        PointRow(action: 'Wicket (Excluding run out)', value: '+ 20 pts'),
        PointRow(action: 'Bonus (LBW/Bowled)', value: '+ 8 pts'),
        PointRow(action: '4 Wicket Bonus', value: '+ 4 pts'),
        PointRow(action: '5 Wicket Bonus', value: '+ 8 pts'),
        PointRow(action: '6 Wicket Bonus', value: '+ 12 pts'),
      ];
    }
  }

  // Fielding Points generator
  List<PointRow> _getFieldingPoints(String matchType) {
    final list = [
      PointRow(action: 'Catch', value: '+ 8 pts'),
    ];

    if (matchType == 'T20' || matchType == 'ODI') {
      list.add(PointRow(action: '3 Catch Bonus', value: '+ 4 pts'));
    }

    list.addAll([
      PointRow(action: 'Stumping', value: '+ 12 pts'),
      PointRow(action: 'Run out (Direct Hit)', value: '+ 12 pts'),
      PointRow(action: 'Run out (Not a Direct Hit)', value: '+ 6 pts'),
    ]);

    return list;
  }

  // Other Points generator
  List<PointRow> _getOtherPoints(String matchType) {
    return [
      PointRow(action: 'Captain Points', value: '2x'),
      PointRow(action: 'Vice Captain Points', value: '1.5x'),
      PointRow(action: 'Playing 11', value: '+ 4 pts'),
      PointRow(action: 'Playing Substitute', value: '+ 4 pts'),
    ];
  }
}

class PointRow {
  final String action;
  final String value;
  final String? description;

  PointRow({
    required this.action,
    required this.value,
    this.description,
  });
}
