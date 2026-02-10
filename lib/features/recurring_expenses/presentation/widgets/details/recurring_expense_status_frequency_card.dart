// Recurring Expense Details - Status & Frequency Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class RecurringExpenseStatusFrequencyCard extends StatelessWidget {
  final RecurringExpense recurringExpense;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const RecurringExpenseStatusFrequencyCard({
    super.key,
    required this.recurringExpense,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: settings.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'الحالة ونوع التكرار' : 'Status & Frequency',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.toggle_on,
                  isRTL ? 'الحالة' : 'Status',
                  recurringExpense.isActive
                      ? (isRTL ? 'نشط' : 'Active')
                      : (isRTL ? 'غير نشط' : 'Inactive'),
                  recurringExpense.isActive
                      ? (settings.isDarkMode
                          ? Colors.green.shade400
                          : Colors.green.shade700)
                      : (settings.isDarkMode
                          ? Colors.red.shade400
                          : Colors.red.shade700),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  Icons.repeat,
                  isRTL ? 'نوع التكرار' : 'Frequency',
                  recurringExpense.recurrenceType.displayName,
                  _getFrequencyColor(recurringExpense.recurrenceType),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isDesktop ? 24 : 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 10,
              color: settings.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: settings.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getFrequencyColor(RecurrenceType type) {
    final isDarkMode = settings.isDarkMode;
    switch (type) {
      case RecurrenceType.daily:
        return isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700;
      case RecurrenceType.weekly:
        return isDarkMode ? Colors.green.shade400 : Colors.green.shade700;
      case RecurrenceType.monthly:
        return isDarkMode ? Colors.orange.shade400 : Colors.orange.shade700;
      case RecurrenceType.yearly:
        return isDarkMode ? Colors.purple.shade400 : Colors.purple.shade700;
    }
  }
}
