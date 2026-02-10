import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

/// Extension to make it easy to get theme-aware colors from BuildContext.
/// Uses the centralized AppColors design system.
extension ThemeHelper on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ─── Text Colors ───
  Color get primaryTextColor =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get secondaryTextColor =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color get tertiaryTextColor =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  // ─── Surface/Background Colors ───
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;

  Color get backgroundCardColor =>
      isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  // ─── Border/Divider Colors ───
  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;

  Color get dividerColor =>
      isDarkMode ? AppColors.dividerDark : AppColors.dividerLight;

  // ─── Icon Colors ───
  Color get iconColor => isDarkMode ? AppColors.iconDark : AppColors.iconLight;

  Color get inactiveIconColor =>
      isDarkMode ? AppColors.iconInactiveDark : AppColors.iconInactiveLight;

  // ─── Status Colors ───
  Color get successColor =>
      isDarkMode ? AppColors.darkSuccess : AppColors.success;

  Color get warningColor =>
      isDarkMode ? AppColors.darkWarning : AppColors.warning;

  Color get errorColor => isDarkMode ? AppColors.darkError : AppColors.error;

  Color get infoColor => isDarkMode ? AppColors.darkInfo : AppColors.info;

  // ─── Empty State Colors ───
  Color get emptyStateIconColor =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textDisabledLight;

  Color get emptyStateTitleColor =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color get emptyStateSubtitleColor =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  // ─── Primary Color ───
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  // ─── Adaptive Color Helper ───
  Color getAdaptiveColor(Color lightColor, Color darkColor) {
    return isDarkMode ? darkColor : lightColor;
  }
}

/// Helper class to get theme-aware colors from SettingsState.
/// Uses the centralized AppColors design system.
class ThemeColors {
  final SettingsState settings;

  ThemeColors(this.settings);

  bool get _isDark => settings.isDarkMode;

  Color get primaryText =>
      _isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get secondaryText =>
      _isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get tertiaryText =>
      _isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get surface => _isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get backgroundCard =>
      _isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
  Color get border => _isDark ? AppColors.borderDark : AppColors.borderLight;
  Color get divider => _isDark ? AppColors.dividerDark : AppColors.dividerLight;
  Color get icon => _isDark ? AppColors.iconDark : AppColors.iconLight;
  Color get inactiveIcon =>
      _isDark ? AppColors.iconInactiveDark : AppColors.iconInactiveLight;
  Color get success => _isDark ? AppColors.darkSuccess : AppColors.success;
  Color get warning => _isDark ? AppColors.darkWarning : AppColors.warning;
  Color get error => _isDark ? AppColors.darkError : AppColors.error;
  Color get info => _isDark ? AppColors.darkInfo : AppColors.info;
  Color get emptyStateIcon =>
      _isDark ? AppColors.textTertiaryDark : AppColors.textDisabledLight;
  Color get emptyStateTitle =>
      _isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get emptyStateSubtitle =>
      _isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
}
