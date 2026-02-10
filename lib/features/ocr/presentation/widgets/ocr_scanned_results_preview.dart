import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/core/constants/categories.dart';

class OcrScannedResultsPreview extends StatelessWidget {
  const OcrScannedResultsPreview({
    super.key,
    required this.expense,
    required this.settings,
    required this.isRTL,
  });

  final Expense expense;
  final SettingsState settings;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                isRTL ? 'تم استخراج البيانات' : 'Data Extracted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            Icons.attach_money,
            isRTL ? 'المبلغ' : 'Amount',
            expense.amount.toStringAsFixed(2),
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            Categories.getIcon(expense.category),
            isRTL ? 'الفئة' : 'Category',
            expense.getDisplayCategoryName(),
          ),
          if (expense.vendorName != null && expense.vendorName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildResultRow(
              Icons.store,
              isRTL ? 'المورد' : 'Vendor',
              expense.vendorName!,
            ),
          ],
          const SizedBox(height: 12),
          _buildResultRow(
            Icons.calendar_today,
            isRTL ? 'التاريخ' : 'Date',
            '${expense.date.day}/${expense.date.month}/${expense.date.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: settings.primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: settings.primaryTextColor.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
