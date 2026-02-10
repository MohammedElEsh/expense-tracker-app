// Add Expense - Category Selector Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/constants/category_constants.dart'
    show CategoryType;

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final bool isBusinessMode;
  final bool isRTL;
  final Function(String) onChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.isBusinessMode,
    required this.isRTL,
    required this.onChanged,
  });

  String _getCategoryLabel(String category) {
    return Categories.getDisplayName(category, isRTL);
  }

  @override
  Widget build(BuildContext context) {
    // Get expense categories from CategoryConstants
    var categories = Categories.reorderCategories(
      Categories.getCategoriesForType(isBusinessMode, CategoryType.expense),
    );

    // Handle empty categories safely (should not happen, but safety check)
    if (categories.isEmpty) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: isRTL ? 'الفئة' : 'Category',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.category),
        ),
        items: const [],
        hint: Text(isRTL ? 'لا توجد فئات' : 'No categories available'),
        onChanged: null,
      );
    }

    // ✅ التحقق من أن الفئة المحددة موجودة في القائمة الحالية
    final validSelectedCategory =
        categories.contains(selectedCategory)
            ? selectedCategory
            : Categories.getDefaultCategoryForType(
              isBusinessMode,
              CategoryType.expense,
            );

    return DropdownButtonFormField<String>(
      value: validSelectedCategory,
      decoration: InputDecoration(
        labelText: isRTL ? 'الفئة' : 'Category',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Categories.getIcon(validSelectedCategory)),
      ),
      items:
          categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(Categories.getIcon(category), size: 20),
                  const SizedBox(width: 12),
                  Text(_getCategoryLabel(category)),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
