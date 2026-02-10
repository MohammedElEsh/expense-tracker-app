import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
/// All colors should be referenced from here - never hardcode Colors.xxx in widgets.
class AppColors {
  AppColors._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF2196F3); // Blue 500
  static const Color primaryLight = Color(0xFF64B5F6); // Blue 300
  static const Color primaryDark = Color(0xFF1565C0); // Blue 800
  static const Color secondary = Color(0xFF4CAF50); // Green 500
  static const Color accent = Color(0xFFFFC107); // Amber 500

  // ─── Dark Theme Brand Colors ───
  static const Color darkPrimary = Color(0xFF4FC3F7); // Light Blue 300
  static const Color darkPrimaryLight = Color(0xFF80DEEA);
  static const Color darkPrimaryDark = Color(0xFF0277BD);
  static const Color darkSecondary = Color(0xFF81C784); // Green 300

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─── Dark Semantic Colors ───
  static const Color darkSuccess = Color(0xFF81C784);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkInfo = Color(0xFF4FC3F7);

  // ─── Surface Colors (Light) ───
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color cardLight = Colors.white;

  // ─── Surface Colors (Dark) ───
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color cardDark = Color(0xFF1E1E1E);

  // ─── Text Colors (Light) ───
  static const Color textPrimaryLight = Color(0xFF212121); // Grey 900
  static const Color textSecondaryLight = Color(0xFF757575); // Grey 600
  static const Color textTertiaryLight = Color(0xFF9E9E9E); // Grey 500
  static const Color textDisabledLight = Color(0xFFBDBDBD); // Grey 400

  // ─── Text Colors (Dark) ───
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFCACACA);
  static const Color textTertiaryDark = Color(0xFF9E9E9E);
  static const Color textDisabledDark = Color(0xFF757575);

  // ─── Border Colors ───
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF5C5C5C);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF424242);

  // ─── Icon Colors ───
  static const Color iconLight = Color(0xFF757575);
  static const Color iconDark = Color(0xFFCACACA);
  static const Color iconInactiveLight = Color(0xFFBDBDBD);
  static const Color iconInactiveDark = Color(0xFF757575);

  // ─── Chart Colors ───
  static const List<Color> chartColorsLight = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF009688), // Teal
    Color(0xFFFFC107), // Amber
    Color(0xFF795548), // Brown
  ];

  static const List<Color> chartColorsDark = [
    Color(0xFF4FC3F7), // Light Blue
    Color(0xFF81C784), // Light Green
    Color(0xFFFFB74D), // Light Orange
    Color(0xFFCF6679), // Light Red
    Color(0xFFBA68C8), // Light Purple
    Color(0xFF4DB6AC), // Light Teal
    Color(0xFFFFD54F), // Light Amber
    Color(0xFFBCAAA4), // Light Brown
  ];

  // ─── Status Badge Colors ───
  static const Color badgeActive = Color(0xFF4CAF50);
  static const Color badgeInactive = Color(0xFF9E9E9E);
  static const Color badgePremium = Color(0xFFFFC107);
  static const Color badgeNew = Color(0xFF2196F3);

  // ─── Category Colors ─── (for expense categories)
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFFF7043),
    'Transport': Color(0xFF42A5F5),
    'Shopping': Color(0xFFAB47BC),
    'Bills': Color(0xFFEF5350),
    'Health': Color(0xFF66BB6A),
    'Education': Color(0xFF5C6BC0),
    'Entertainment': Color(0xFFFFA726),
    'Other': Color(0xFF78909C),
  };
}
