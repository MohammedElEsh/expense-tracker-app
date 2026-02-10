// Category Constants - Single Source of Truth
//
// These constants match the backend categories EXACTLY (including Arabic characters, spaces, hamza, spelling).
// DO NOT modify these values unless the backend changes.
//
// Backend source of truth:
// 1) budgetCategory - PERSONAL_CATEGORIES and BUSINESS_CATEGORIES
// 2) expensesCategory - PERSONAL_CATEGORIES and BUSINESS_CATEGORIES
// 3) RecurringExpenseCategory - PERSONAL_CATEGORIES and BUSINESS_CATEGORIES

/// Category type enum
///
/// Used to distinguish between different category types in the app.
enum CategoryType { budget, expense, recurringExpense }

class CategoryConstants {
  // ===========================================================================
  // BUDGET CATEGORIES (budgetCategory)
  // ===========================================================================

  /// Personal categories for budgets (from backend budgetCategory PERSONAL_CATEGORIES)
  static const List<String> budgetPersonalCategories = [
    'طعام ومطاعم',
    'مواصلات وتنقل',
    'ترفيه وتسلية',
    'تسوق',
    'فواتير واشتراكات',
    'صحة ورعاية طبية',
    'أخرى',
  ];

  /// Business categories for budgets (from backend budgetCategory BUSINESS_CATEGORIES)
  static const List<String> budgetBusinessCategories = [
    'اخرى',
    'ضرائب',
    'تامين',
    'مشتريات مكتبية',
    'سفروانتقالات ',
    'تسويق واعلانات',
    'صيانة عدادات',
    'فواتير مياه',
    'فواتير كهرباء',
    'ايجار المكتب',
    'رواتب الموظفين',
  ];

  // ===========================================================================
  // EXPENSE CATEGORIES (expensesCategory)
  // ===========================================================================

  /// Personal categories for expenses (from backend expensesCategory PERSONAL_CATEGORIES)
  static const List<String> expensePersonalCategories = [
    'طعام ومطاعم',
    'مواصلات وتنقل',
    'ترفيه وتسلية',
    'تسوق',
    'فواتير واشتراكات',
    'صحة ورعاية طبية',
    'أخرى',
  ];

  /// Business categories for expenses (from backend expensesCategory BUSINESS_CATEGORIES)
  static const List<String> expenseBusinessCategories = [
    'أجور',
    'إيجار',
    'فواتير',
    'مستلزمات',
    'تسويق',
    'سفر',
    'أخرى',
    'صيانة وإصلاحات',
    'تسويق وإعلانات',
    'تدريب وتطوير',
    'ضرائب ورسوم',
    'فوائد بنكية',
    'طعام ومشروبات',
  ];

  // ===========================================================================
  // RECURRING EXPENSE CATEGORIES (RecurringExpenseCategory)
  // ===========================================================================

  /// Personal categories for recurring expenses (from backend RecurringExpenseCategory PERSONAL_CATEGORIES)
  static const List<String> recurringExpensePersonalCategories = [
    'طعام ومطاعم',
    'مواصلات وتنقل',
    'ترفيه وتسلية',
    'تسوق',
    'فواتير واشتراكات',
    'صحة ورعاية طبية',
    'أخرى',
  ];

  /// Business categories for recurring expenses (from backend RecurringExpenseCategory BUSINESS_CATEGORIES)
  static const List<String> recurringExpenseBusinessCategories = [
    'أجور',
    'إيجار',
    'فواتير',
    'مستلزمات',
    'تسويق',
    'سفر',
    'أخرى',
    'صيانة وإصلاحات',
    'ضرائب ورسوم',
    'فوائد بنكية',
    'تدريب وتطوير',
    'تسويق وإعلانات',
  ];

  // ===========================================================================
  // VALIDATION HELPERS
  // ===========================================================================

  /// Check if a category is valid for the given app mode and category type
  ///
  /// [isBusinessMode] - true for business mode, false for personal mode
  /// [categoryType] - budget, expense, or recurringExpense
  /// [value] - the category string to validate
  ///
  /// Returns true if the category exists in the appropriate list
  static bool isValidCategory(
    bool isBusinessMode,
    CategoryType categoryType,
    String value,
  ) {
    final normalizedValue = normalizeCategory(value);

    switch (categoryType) {
      case CategoryType.budget:
        return isBusinessMode
            ? budgetBusinessCategories.contains(normalizedValue)
            : budgetPersonalCategories.contains(normalizedValue);

      case CategoryType.expense:
        return isBusinessMode
            ? expenseBusinessCategories.contains(normalizedValue)
            : expensePersonalCategories.contains(normalizedValue);

      case CategoryType.recurringExpense:
        return isBusinessMode
            ? recurringExpenseBusinessCategories.contains(normalizedValue)
            : recurringExpensePersonalCategories.contains(normalizedValue);
    }
  }

  /// Normalize category string (only trims trailing spaces if backend doesn't include them)
  ///
  /// Note: Some backend categories have trailing spaces (e.g., 'سفروانتقالات ')
  /// This function preserves backend format exactly, only trimming if needed
  static String normalizeCategory(String value) {
    // Trim only if the backend version doesn't have trailing spaces
    // For now, we preserve the exact backend format
    // If a category has trailing space in backend, it will be preserved

    // Check if any backend category has trailing space
    final hasTrailingSpace = budgetBusinessCategories.any(
      (cat) => cat.endsWith(' '),
    );

    if (hasTrailingSpace) {
      // If backend has categories with trailing spaces, preserve them
      return value;
    } else {
      // Otherwise, trim trailing spaces
      return value.trimRight();
    }
  }

  /// Get categories for the given mode and category type
  static List<String> getCategories(
    bool isBusinessMode,
    CategoryType categoryType,
  ) {
    switch (categoryType) {
      case CategoryType.budget:
        return isBusinessMode
            ? budgetBusinessCategories
            : budgetPersonalCategories;

      case CategoryType.expense:
        return isBusinessMode
            ? expenseBusinessCategories
            : expensePersonalCategories;

      case CategoryType.recurringExpense:
        return isBusinessMode
            ? recurringExpenseBusinessCategories
            : recurringExpensePersonalCategories;
    }
  }

  /// Get default category for the given mode and category type
  static String getDefaultCategory(
    bool isBusinessMode,
    CategoryType categoryType,
  ) {
    final categories = getCategories(isBusinessMode, categoryType);
    return categories.isNotEmpty ? categories.first : 'أخرى';
  }
}
