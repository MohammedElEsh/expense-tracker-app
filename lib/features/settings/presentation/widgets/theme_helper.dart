// ✅ Clean Architecture - Theme Helper Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

/// Extension to make it easy to get theme-aware colors from BuildContext
extension ThemeHelper on BuildContext {
  /// Get text colors that adapt to dark mode
  Color get primaryTextColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFE8E8E8)
        : Colors.black87;
  }

  Color get secondaryTextColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFCACACA)
        : Colors.black54;
  }

  Color get tertiaryTextColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF9E9E9E)
        : Colors.grey[600]!;
  }

  /// Get surface/background colors
  Color get surfaceColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  Color get backgroundCardColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF5F5F5);
  }

  Color get backgroundColor {
    return Theme.of(this).scaffoldBackgroundColor;
  }

  /// Get border/divider colors
  Color get borderColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF5C5C5C)
        : Colors.grey.shade300;
  }

  Color get dividerColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF5C5C5C)
        : Colors.grey.shade200;
  }

  /// Get icon colors
  Color get iconColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFCACACA)
        : Colors.grey.shade600;
  }

  Color get inactiveIconColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF9E9E9E)
        : Colors.grey.shade400;
  }

  /// Get status colors
  Color get successColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF81C784)
        : Colors.green;
  }

  Color get warningColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFFFB74D)
        : Colors.orange;
  }

  Color get errorColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? const Color(0xFFCF6679) : Colors.red;
  }

  Color get infoColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF4FC3F7)
        : Colors.blue;
  }

  /// Get empty state colors
  Color get emptyStateIconColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? Colors.grey[500]!
        : Colors.grey[400]!;
  }

  Color get emptyStateTitleColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[600]!;
  }

  Color get emptyStateSubtitleColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[500]!;
  }

  /// Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get primary color
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Get color with opacity based on theme
  Color getAdaptiveColor(Color lightColor, Color darkColor) {
    return isDarkMode ? darkColor : lightColor;
  }
}

/// Helper function to get theme-aware colors from SettingsState
class ThemeColors {
  final SettingsState settings;

  ThemeColors(this.settings);

  Color get primaryText =>
      settings.isDarkMode ? const Color(0xFFE8E8E8) : Colors.black87;

  Color get secondaryText =>
      settings.isDarkMode ? const Color(0xFFCACACA) : Colors.black54;

  Color get tertiaryText =>
      settings.isDarkMode ? const Color(0xFF9E9E9E) : Colors.grey.shade600;

  Color get surface =>
      settings.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Color get backgroundCard =>
      settings.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);

  Color get border =>
      settings.isDarkMode ? const Color(0xFF5C5C5C) : Colors.grey.shade300;

  Color get divider =>
      settings.isDarkMode ? const Color(0xFF5C5C5C) : Colors.grey.shade200;

  Color get icon =>
      settings.isDarkMode ? const Color(0xFFCACACA) : Colors.grey.shade600;

  Color get inactiveIcon =>
      settings.isDarkMode ? const Color(0xFF9E9E9E) : Colors.grey.shade400;

  Color get success =>
      settings.isDarkMode ? const Color(0xFF81C784) : Colors.green;

  Color get warning =>
      settings.isDarkMode ? const Color(0xFFFFB74D) : Colors.orange;

  Color get error => settings.isDarkMode ? const Color(0xFFCF6679) : Colors.red;

  Color get info => settings.isDarkMode ? const Color(0xFF4FC3F7) : Colors.blue;

  Color get emptyStateIcon =>
      settings.isDarkMode ? Colors.grey[500]! : Colors.grey[400]!;

  Color get emptyStateTitle =>
      settings.isDarkMode ? Colors.grey[300]! : Colors.grey[600]!;

  Color get emptyStateSubtitle =>
      settings.isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;
}
