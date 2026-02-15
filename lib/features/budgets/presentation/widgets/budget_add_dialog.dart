// Budget Add Dialog - نافذة إضافة ميزانية
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/constants/category_constants.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';

class BudgetAddDialog extends StatefulWidget {
  final DateTime selectedMonth;
  final bool isRTL;
  final AppMode appMode;
  final Function(String category, double limit) onSave;

  const BudgetAddDialog({
    super.key,
    required this.selectedMonth,
    required this.isRTL,
    required this.appMode,
    required this.onSave,
  });

  @override
  State<BudgetAddDialog> createState() => _BudgetAddDialogState();
}

class _BudgetAddDialogState extends State<BudgetAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  late String _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    // Get budget categories based on app mode and reorder to ensure "أخرى" or "اخرى" is last
    final isBusinessMode = widget.appMode == AppMode.business;
    _categories = Categories.reorderCategories(
      Categories.getCategoriesForType(isBusinessMode, CategoryType.budget),
    );
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isRTL ? 'إضافة ميزانية' : 'Add Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: widget.isRTL ? 'الفئة' : 'Category',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Categories.getIcon(_selectedCategory)),
              ),
              items:
                  _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            Categories.getIcon(category),
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Categories.getDisplayName(category, widget.isRTL),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Limit TextField
            TextFormField(
              controller: _limitController,
              decoration: InputDecoration(
                labelText: widget.isRTL ? 'الحد المسموح' : 'Limit',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.account_balance_wallet),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.isRTL
                      ? 'الرجاء إدخال المبلغ'
                      : 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return widget.isRTL
                      ? 'الرجاء إدخال مبلغ صحيح'
                      : 'Please enter valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(widget.isRTL ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(widget.isRTL ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_selectedCategory, double.parse(_limitController.text));
    }
  }
}
