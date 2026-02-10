import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/category_constants.dart';

/// Categories utility class
/// Categories are static and defined locally - no API calls needed
/// This class provides utility methods for icon mapping and display names
///
/// NOTE: This class now uses CategoryConstants as the single source of truth.
/// For backward compatibility, personalCategories and businessCategories default to expense categories.
class Categories {
  /// Personal categories (defaults to expense categories for backward compatibility)
  /// Use getCategoriesForType() for specific category types
  static List<String> get personalCategories =>
      CategoryConstants.expensePersonalCategories;

  /// Business categories (defaults to expense categories for backward compatibility)
  /// Use getCategoriesForType() for specific category types
  static List<String> get businessCategories =>
      CategoryConstants.expenseBusinessCategories;

  /// Icon mappings for categories (API categories are in Arabic)
  /// Includes all categories from budget, expense, and recurring expense types
  static const Map<String, IconData> icons = {
    // Personal categories (common across all types)
    'طعام ومطاعم': Icons.restaurant,
    'مواصلات وتنقل': Icons.directions_car,
    'ترفيه وتسلية': Icons.movie,
    'تسوق': Icons.shopping_bag,
    'فواتير واشتراكات': Icons.receipt,
    'صحة ورعاية طبية': Icons.local_hospital,
    'أخرى': Icons.category,

    // Business expense/recurring categories
    'طعام ومشروبات': Icons.restaurant,
    'فواتير': Icons.receipt,
    'مستلزمات': Icons.inventory,
    'تسويق': Icons.campaign,
    'سفر': Icons.flight,
    'إيجار': Icons.business,
    'أجور': Icons.people,
    'ضرائب ورسوم': Icons.account_balance,
    'فوائد بنكية': Icons.account_balance_wallet,
    'تدريب وتطوير': Icons.school,
    'تسويق وإعلانات': Icons.campaign,
    'صيانة وإصلاحات': Icons.build,

    // Business budget categories
    'اخرى': Icons.category,
    'ضرائب': Icons.account_balance,
    'تامين': Icons.shield,
    'مشتريات مكتبية': Icons.inventory_2,
    'سفروانتقالات ': Icons.flight,
    'تسويق واعلانات': Icons.campaign,
    'صيانة عدادات': Icons.build,
    'فواتير مياه': Icons.water_drop,
    'فواتير كهرباء': Icons.bolt,
    'ايجار المكتب': Icons.business,
    'رواتب الموظفين': Icons.people,
  };

  /// Get icon for a category
  /// Returns Icons.category as fallback if category not found
  static IconData getIcon(String category) {
    return icons[category] ?? Icons.category;
  }

  /// Get display name for a category
  /// Since API categories are already in Arabic, this just returns the category as-is
  static String getDisplayName(String category, bool isRTL) {
    // API categories are already in Arabic, so just return as-is
    return category;
  }

  /// Get Arabic name (for backward compatibility)
  /// Since API categories are already in Arabic, this just returns the category as-is
  static String getArabicName(String category) {
    return category;
  }

  /// Check if a category is a personal category
  static bool isPersonalCategory(String category) {
    return personalCategories.contains(category);
  }

  /// Check if a category is a business category
  static bool isBusinessCategory(String category) {
    return businessCategories.contains(category);
  }

  /// Get categories for the given mode (defaults to expense categories for backward compatibility)
  /// Use getCategoriesForType() for specific category types (budget, expense, recurringExpense)
  static List<String> getCategoriesForMode(bool isBusinessMode) {
    return isBusinessMode ? businessCategories : personalCategories;
  }

  /// Get categories for the given mode and category type
  ///
  /// [isBusinessMode] - true for business mode, false for personal mode
  /// [categoryType] - budget, expense, or recurringExpense
  static List<String> getCategoriesForType(
    bool isBusinessMode,
    CategoryType categoryType,
  ) {
    return CategoryConstants.getCategories(isBusinessMode, categoryType);
  }

  /// Reorder categories to ensure "أخرى" or "اخرى" is always last
  /// Keeps API order but moves "أخرى" or "اخرى" to the end if it exists
  static List<String> reorderCategories(List<String> categories) {
    if (categories.isEmpty) return categories;

    // Check if "أخرى" (with hamza) or "اخرى" (without hamza) exists in the list
    final hasOtherWithHamza = categories.contains('أخرى');
    final hasOtherWithoutHamza = categories.contains('اخرى');

    if (!hasOtherWithHamza && !hasOtherWithoutHamza) {
      // If neither exists, return categories as-is
      return categories;
    }

    // Remove the "other" category from its current position and add it to the end
    final reordered = List<String>.from(categories);
    if (hasOtherWithHamza) {
      reordered.remove('أخرى');
      reordered.add('أخرى');
    } else if (hasOtherWithoutHamza) {
      reordered.remove('اخرى');
      reordered.add('اخرى');
    }

    return reordered;
  }

  /// Get default category for the given mode (defaults to expense categories for backward compatibility)
  /// Use getDefaultCategoryForType() for specific category types
  static String getDefaultCategory(bool isBusinessMode) {
    return isBusinessMode ? businessCategories.first : personalCategories.first;
  }

  /// Get default category for the given mode and category type
  ///
  /// [isBusinessMode] - true for business mode, false for personal mode
  /// [categoryType] - budget, expense, or recurringExpense
  static String getDefaultCategoryForType(
    bool isBusinessMode,
    CategoryType categoryType,
  ) {
    return CategoryConstants.getDefaultCategory(isBusinessMode, categoryType);
  }

  /// Validate if a category is valid for the given mode and category type
  ///
  /// [isBusinessMode] - true for business mode, false for personal mode
  /// [categoryType] - budget, expense, or recurringExpense
  /// [category] - the category string to validate
  static bool isValidCategory(
    bool isBusinessMode,
    CategoryType categoryType,
    String category,
  ) {
    return CategoryConstants.isValidCategory(
      isBusinessMode,
      categoryType,
      category,
    );
  }

  /// Normalize category string (preserves backend format exactly)
  static String normalizeCategory(String category) {
    return CategoryConstants.normalizeCategory(category);
  }
}
