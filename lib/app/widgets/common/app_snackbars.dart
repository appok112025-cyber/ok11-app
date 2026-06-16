import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ok11/app/theme/app_colors.dart';

class AppSnackbars {
  static BuildContext? _getContext(BuildContext? context) {
    return context ?? Get.context;
  }

  static double _getBottomMargin(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentRoute = Get.currentRoute;
    final hasBottomBar = currentRoute == '/' || 
                         currentRoute == '/dashboard' || 
                         currentRoute.isEmpty;
    
    return hasBottomBar ? bottomPadding + 88.0 : bottomPadding + 20.0;
  }

  static void showInfo(String message, [BuildContext? context]) {
    final ctx = _getContext(context);
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: _getBottomMargin(ctx),
          left: 16,
          right: 16,
        ),
        duration: const Duration(milliseconds: 2000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showError(String message, [BuildContext? context]) {
    final ctx = _getContext(context);
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: _getBottomMargin(ctx),
          left: 16,
          right: 16,
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(milliseconds: 2000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccess(String message, [BuildContext? context]) {
    final ctx = _getContext(context);
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: _getBottomMargin(ctx),
          left: 16,
          right: 16,
        ),
        duration: const Duration(milliseconds: 2000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showWarning(String message, [BuildContext? context]) {
    final ctx = _getContext(context);
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentOrange,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: _getBottomMargin(ctx),
          left: 16,
          right: 16,
        ),
        duration: const Duration(milliseconds: 2000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
