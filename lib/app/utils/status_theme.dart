import 'package:flutter/material.dart';
import 'package:ok11/app/theme/app_colors.dart';

enum MatchStatus { upcoming, live, completed, cancelled }

class StatusTheme {
  static final Map<MatchStatus, _StatusColors> _themes = {
    MatchStatus.upcoming: _StatusColors(
      header: AppColors.primary.withValues(alpha: 0.15),
      text: AppColors.primary,
      border: AppColors.primary.withValues(alpha: 0.3),
      shadow: AppColors.primary.withValues(alpha: 0.12),
      badge: AppColors.primary,
      badgeBorder: AppColors.primary.withValues(alpha: 0.5),
      badgeText: Colors.white,
      textLabel: 'upcoming',
    ),
    MatchStatus.live: _StatusColors(
      header: AppColors.primary.withValues(alpha: 0.2),
      text: AppColors.primary,
      border: AppColors.primary.withValues(alpha: 0.4),
      shadow: AppColors.primary.withValues(alpha: 0.15),
      badge: AppColors.primary,
      badgeBorder: AppColors.primary.withValues(alpha: 0.7),
      badgeText: Colors.white,
      textLabel: 'Live',
    ),
    MatchStatus.completed: _StatusColors(
      header: AppColors.primary.withValues(alpha: 0.15),
      text: AppColors.primary,
      border: AppColors.primary.withValues(alpha: 0.3),
      shadow: AppColors.primary.withValues(alpha: 0.12),
      badge: AppColors.primary,
      badgeBorder: AppColors.primary.withValues(alpha: 0.5),
      badgeText: Colors.white,
      textLabel: 'completed',
    ),
    MatchStatus.cancelled: _StatusColors(
      header: AppColors.accentPink.withValues(alpha: 0.15),
      text: AppColors.accentPink,
      border: AppColors.accentPink.withValues(alpha: 0.3),
      shadow: AppColors.accentPink.withValues(alpha: 0.12),
      badge: AppColors.accentPink,
      badgeBorder: AppColors.accentPink.withValues(alpha: 0.5),
      badgeText: Colors.white,
      textLabel: 'cancelled',
    ),
  };

  static Color getHeaderColor(MatchStatus status) => _themes[status]!.header;
  static Color getTextColor(MatchStatus status) => _themes[status]!.text;
  static Color getBorderColor(MatchStatus status) => _themes[status]!.border;
  static Color getShadowColor(MatchStatus status) => _themes[status]!.shadow;
  static Color getBadgeColor(MatchStatus status) => _themes[status]!.badge;
  static Color getBadgeBorderColor(MatchStatus status) =>
      _themes[status]!.badgeBorder;
  static Color getBadgeTextColor(MatchStatus status) =>
      _themes[status]!.badgeText;
  static String getTextLabel(MatchStatus status) => _themes[status]!.textLabel;
}

class _StatusColors {
  final Color header;
  final Color text;
  final Color border;
  final Color shadow;
  final Color badge;
  final Color badgeBorder;
  final Color badgeText;
  final String textLabel;

  _StatusColors({
    required this.header,
    required this.text,
    required this.border,
    required this.shadow,
    required this.badge,
    required this.badgeBorder,
    required this.badgeText,
    required this.textLabel,
  });
}
