import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = isDark ? AppColors.darkSuccess : AppColors.success;
        foregroundColor = Colors.white;
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackBarType.error:
        backgroundColor = isDark ? AppColors.darkError : AppColors.error;
        foregroundColor = Colors.white;
        icon = Icons.error_outline_rounded;
        break;
      case SnackBarType.warning:
        backgroundColor = isDark ? AppColors.darkWarning : AppColors.warning;
        foregroundColor = Colors.white;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = isDark ? AppColors.darkInfo : AppColors.info;
        foregroundColor = Colors.white;
        icon = Icons.info_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: duration,
        action:
            actionLabel != null && onAction != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: foregroundColor,
                  onPressed: onAction,
                )
                : null,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackBarType.info);
}
