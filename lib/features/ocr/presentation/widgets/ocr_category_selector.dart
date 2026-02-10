import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/constants/categories.dart';

class OcrCategorySelector extends StatelessWidget {
  const OcrCategorySelector({
    super.key,
    required this.settings,
    required this.isRTL,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final SettingsState settings;
  final bool isRTL;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final categories = Categories.reorderCategories(
      Categories.getCategoriesForMode(settings.isBusinessMode),
    );
    final categoryIcon =
        selectedCategory != null
            ? Categories.getIcon(selectedCategory!)
            : Icons.category;

    return Container(
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settings.primaryColor.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: isRTL ? 'الفئة (اختياري)' : 'Category (Optional)',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(categoryIcon, color: settings.primaryColor),
          helperText:
              isRTL
                  ? 'اختياري - سيتم تخمينها تلقائياً'
                  : 'Optional - will be auto-detected',
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              isRTL ? 'تخمين تلقائي' : 'Auto-detect',
              style: TextStyle(
                color: settings.primaryTextColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          ...categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(Categories.getIcon(category), size: 20),
                  const SizedBox(width: 12),
                  Text(Categories.getDisplayName(category, isRTL)),
                ],
              ),
            );
          }),
        ],
        onChanged: onCategoryChanged,
      ),
    );
  }
}
