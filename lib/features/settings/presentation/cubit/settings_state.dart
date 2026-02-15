import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class SettingsState extends Equatable {
  final String currency;
  final String currencySymbol;
  final List<String> availableCurrencies;
  final Map<String, String> codeToSymbol;
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
    this.currencySymbol = 'ر.س',
    this.availableCurrencies = const ['SAR', 'EGP', 'USD', 'GBP', 'EUR', 'JPY', 'AED'],
    this.codeToSymbol = const {
      'SAR': 'ر.س', 'EGP': 'ج.م', 'USD': '\$', 'GBP': '£', 'EUR': '€', 'JPY': '¥', 'AED': 'د.إ',
    },
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
    currencySymbol,
    availableCurrencies,
    codeToSymbol,
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

  String symbolFor(String code) => codeToSymbol[code] ?? code;

  SettingsState copyWith({
    String? currency,
    String? currencySymbol,
    List<String>? availableCurrencies,
    Map<String, String>? codeToSymbol,
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
      currencySymbol: currencySymbol ?? this.currencySymbol,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      codeToSymbol: codeToSymbol ?? this.codeToSymbol,
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
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: AppSpacing.elevationMd,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppSpacing.elevationSm,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: const TextStyle(color: AppColors.textTertiaryLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: AppSpacing.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceLight,
        elevation: AppSpacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minVerticalPadding: AppSpacing.xs,
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
      isDarkMode ? AppColors.darkPrimary : AppColors.primary;
  Color get secondaryChartColor =>
      isDarkMode ? AppColors.darkSecondary : AppColors.secondary;
  Color get warningChartColor =>
      isDarkMode ? AppColors.darkWarning : AppColors.warning;
  Color get errorChartColor =>
      isDarkMode ? AppColors.darkError : AppColors.error;

  List<Color> get chartColors =>
      isDarkMode ? AppColors.chartColorsDark : AppColors.chartColorsLight;

  // Semantic status colors
  Color get successColor =>
      isDarkMode ? AppColors.darkSuccess : AppColors.success;
  Color get warningColor =>
      isDarkMode ? AppColors.darkWarning : AppColors.warning;
  Color get errorColor => isDarkMode ? AppColors.darkError : AppColors.error;

  // Surface colors
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get backgroundCardColor =>
      isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

  // Text colors
  Color get primaryTextColor =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get secondaryTextColor =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  // Border colors
  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;

  // Icon colors
  Color get iconColor => isDarkMode ? AppColors.iconDark : AppColors.iconLight;

  // Additional color getters for backwards compatibility
  Color get surfaceContainerHighestColor => backgroundCardColor;
  Color get hintTextColor => secondaryTextColor;
  Color get primaryColor =>
      isDarkMode ? AppColors.darkPrimary : AppColors.primary;
}
