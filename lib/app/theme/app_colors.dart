import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFFE53E3E);

  // Primary color variations
  static Color primaryLight = primary.withValues(alpha: 0.08);
  static Color primaryLighter = primary.withValues(alpha: 0.04);
  static Color primaryDark = const Color(0xFF1565C0);

  // Vibrant accent colors
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color accentGreen = Color(0xFF27AE60);
  static const Color accentYellow = Color(0xFFF39C12);
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentTeal = Color(0xFF16A085);
  static const Color accentRed = Color(0xFFE74C3C);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentIndigo = Color(0xFF5D4E75);

  // Status colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Team colors (cricket teams)
  static const Color teamIndia = Color(0xFFFF9933);
  static const Color teamPakistan = Color(0xFF006600);
  static const Color teamAustralia = Color(0xFF00843D);
  static const Color teamEngland = Color(0xFFCE1126);
  static const Color teamSouthAfrica = Color(0xFF007A4D);
  static const Color teamNewZealand = Color(0xFF000000);
  static const Color teamWestIndies = Color(0xFFFF0000);
  static const Color teamSriLanka = Color(0xFFFFD700);
  static const Color teamBangladesh = Color(0xFF006A4E);
  static const Color teamAfghanistan = Color(0xFF000000);

  // Gradient colors
  static List<Color> get primaryGradient => [primary, const Color(0xFF42A5F5)];

  static List<Color> get successGradient => [accentGreen, accentTeal];

  static List<Color> get warningGradient => [accentYellow, accentOrange];

  static List<Color> get vibrantGradient => [
    accentPurple,
    accentPink,
    accentOrange,
  ];

  static List<Color> get teamGradient => [primary, accentBlue, accentTeal];

  static List<Color> getGradientWithAlpha(List<Color> gradient, double alpha) {
    return gradient.map((c) => c.withValues(alpha: alpha)).toList();
  }
}
