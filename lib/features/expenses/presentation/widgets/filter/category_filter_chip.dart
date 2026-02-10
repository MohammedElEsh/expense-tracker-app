// Expense Filter - Category Filter Chip Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/constants/categories.dart';

class CategoryFilterChip extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final bool isRTL;
  final Function(String?) onCategoryChanged;

  const CategoryFilterChip({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.isRTL,
    required this.onCategoryChanged,
  });

  // Get category label (categories are already in Arabic from backend)
  String _getCategoryLabel(String category) {
    return Categories.getDisplayName(category, isRTL);
  }

  @override
  Widget build(BuildContext context) {
    // Reorder categories to ensure "أخرى" is always last
    final reorderedCategories = Categories.reorderCategories(categories);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            isRTL ? 'الفئة' : 'Category',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(isRTL ? 'الكل' : 'All'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) onCategoryChanged(null);
                  },
                ),
              ),
              // Category chips
              ...reorderedCategories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      onCategoryChanged(selected ? category : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
