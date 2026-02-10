import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';

class SettingsState extends Equatable {
  final String currency;
  final bool isDarkMode;
  final String language;
  final AppMode appMode;
  final bool isLoading;
  final bool hasLoaded;
  final String? error;
  final String? companyName;
  final String? companyLogo;
  final bool notifications;

  const SettingsState({
    this.currency = 'SAR',
    this.isDarkMode = false,
    this.language = 'en',
    this.appMode = AppMode.personal,
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
    this.companyName,
    this.companyLogo,
    this.notifications = false,
  });

  @override
  List<Object?> get props => [
    currency,
    isDarkMode,
    language,
    appMode,
    isLoading,
    hasLoaded,
    error,
    companyName,
    companyLogo,
    notifications,
  ];

  SettingsState copyWith({
    String? currency,
    bool? isDarkMode,
    String? language,
    AppMode? appMode,
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    String? companyName,
    String? companyLogo,
    bool? notifications,
    bool clearError = false,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      appMode: appMode ?? this.appMode,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      notifications: notifications ?? this.notifications,
    );
  }

  // Helper getters
  String get currencySymbol => SettingsService.getCurrencySymbol(currency);

  List<String> get availableCurrencies => SettingsService.availableCurrencies;

  // App Mode helpers
  bool get isPersonalMode => appMode == AppMode.personal;
  bool get isBusinessMode => appMode == AppMode.business;

  String get appModeDisplayName => appMode.getDisplayName(language == 'ar');
  String get appModeDescription => appMode.getDescription(language == 'ar');

  ThemeData get themeData {
    return isDarkMode ? _darkTheme : _lightTheme;
  }

  ThemeData get _lightTheme {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get _darkTheme {
    const darkBackground = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);
    const darkSurfaceVariant = Color(0xFF2C2C2C);
    const darkPrimary = Color(0xFF4FC3F7);
    const darkPrimaryContainer = Color(0xFF0277BD);
    const darkSecondary = Color(0xFF81C784);
    const darkError = Color(0xFFCF6679);
    const darkOnSurface = Color(0xFFE8E8E8);
    const darkOnPrimary = Color(0xFF000000);

    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: darkSecondary,
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF2E7D32),
        onSecondaryContainer: Colors.white,
        error: darkError,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: Color(0xFFCACACA),
        outline: Color(0xFF5C5C5C),
        inverseSurface: Color(0xFFE3E3E3),
        onInverseSurface: Color(0xFF1A1A1A),
        inversePrimary: Color(0xFF0277BD),
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black38,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 6,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: darkPrimary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5C5C5C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5C5C5C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFFCACACA)),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF5C5C5C)),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: Color(0xFF9E9E9E),
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return const Color(0xFF9E9E9E);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary.withValues(alpha: 0.3);
          }
          return const Color(0xFF5C5C5C);
        }),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: Color(0xFF2C2C2C),
        iconColor: Color(0xFFCACACA),
        textColor: darkOnSurface,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF5C5C5C),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        disabledColor: const Color(0xFF5C5C5C),
        selectedColor: darkPrimary.withValues(alpha: 0.3),
        secondarySelectedColor: darkSecondary.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: darkOnSurface),
        secondaryLabelStyle: const TextStyle(color: darkOnSurface),
        brightness: Brightness.dark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Chart colors that adapt to theme
  Color get primaryChartColor =>
      isDarkMode ? const Color(0xFF4FC3F7) : Colors.blue;
  Color get secondaryChartColor =>
      isDarkMode ? const Color(0xFF81C784) : Colors.green;
  Color get warningChartColor =>
      isDarkMode ? const Color(0xFFFFB74D) : Colors.orange;
  Color get errorChartColor =>
      isDarkMode ? const Color(0xFFCF6679) : Colors.red;

  List<Color> get chartColors =>
      isDarkMode
          ? [
            const Color(0xFF4FC3F7), // Blue
            const Color(0xFF81C784), // Green
            const Color(0xFFFFB74D), // Orange
            const Color(0xFFCF6679), // Red
            const Color(0xFFBA68C8), // Purple
            const Color(0xFF4DB6AC), // Teal
            const Color(0xFFFFD54F), // Yellow
          ]
          : [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.red,
            Colors.purple,
            Colors.teal,
            Colors.amber,
          ];

  // Success/Warning/Error colors
  Color get successColor => isDarkMode ? const Color(0xFF81C784) : Colors.green;
  Color get warningColor =>
      isDarkMode ? const Color(0xFFFFB74D) : Colors.orange;
  Color get errorColor => isDarkMode ? const Color(0xFFCF6679) : Colors.red;

  // Surface colors
  Color get surfaceColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get backgroundCardColor =>
      isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);

  // Text colors
  Color get primaryTextColor =>
      isDarkMode ? const Color(0xFFE8E8E8) : Colors.black87;
  Color get secondaryTextColor =>
      isDarkMode ? const Color(0xFFCACACA) : Colors.black54;

  // Border colors
  Color get borderColor =>
      isDarkMode ? const Color(0xFF5C5C5C) : Colors.grey.shade300;

  // Icon colors
  Color get iconColor =>
      isDarkMode ? const Color(0xFFCACACA) : Colors.grey.shade600;

  // Additional color getters for backwards compatibility
  Color get surfaceContainerHighestColor => backgroundCardColor;
  Color get hintTextColor => secondaryTextColor;
  Color get primaryColor => isDarkMode ? const Color(0xFF4FC3F7) : Colors.blue;
}
