import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Shared decoration styles for consistent look and feel.
class AppDecorations {
  AppDecorations._();

  // ─── Card Decorations ───
  static BoxDecoration card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey).withValues(
            alpha: isDark ? 0.3 : 0.08,
          ),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration cardElevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey).withValues(
            alpha: isDark ? 0.4 : 0.12,
          ),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration cardFlat(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color:
          isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    );
  }

  // ─── Input Decorations ───
  static InputDecoration inputDecoration({
    required BuildContext context,
    String? label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
          isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkError : AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }

  // ─── Gradient Decorations ───
  static BoxDecoration gradientCard({
    required Color startColor,
    required Color endColor,
    double radius = AppSpacing.radiusMd,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: startColor.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ─── Badge Decorations ───
  static BoxDecoration badge({
    required Color color,
    double radius = AppSpacing.radiusFull,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    );
  }

  // ─── Chip/Tag Decoration ───
  static BoxDecoration chip({
    required BuildContext context,
    Color? color,
    bool isSelected = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return BoxDecoration(
      color:
          isSelected
              ? chipColor.withValues(alpha: 0.2)
              : isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      border: Border.all(
        color:
            isSelected
                ? chipColor.withValues(alpha: 0.5)
                : isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
      ),
    );
  }

  // ─── Divider ───
  static BoxDecoration sectionDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
    );
  }
}
