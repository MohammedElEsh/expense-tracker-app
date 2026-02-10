// Recurring Expense Details - Schedule Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class RecurringExpenseScheduleCard extends StatelessWidget {
  final RecurringExpense recurringExpense;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const RecurringExpenseScheduleCard({
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
            isRTL ? 'معلومات الجدولة' : 'Schedule Information',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today,
            isRTL ? 'تاريخ الإنشاء' : 'Created Date',
            DateFormat('MMM dd, yyyy').format(recurringExpense.createdAt),
          ),
          const SizedBox(height: 12),
          if (recurringExpense.lastProcessed != null) ...[
            _buildInfoRow(
              Icons.history,
              isRTL ? 'آخر معالجة' : 'Last Processed',
              DateFormat(
                'MMM dd, yyyy',
              ).format(recurringExpense.lastProcessed!),
            ),
            const SizedBox(height: 12),
          ],
          if (recurringExpense.nextDue != null) ...[
            _buildInfoRow(
              Icons.schedule,
              isRTL ? 'الاستحقاق التالي' : 'Next Due',
              DateFormat('MMM dd, yyyy').format(recurringExpense.nextDue!),
            ),
            const SizedBox(height: 12),
          ],
          if (recurringExpense.recurrenceType == RecurrenceType.monthly) ...[
            _buildInfoRow(
              Icons.calendar_month,
              isRTL ? 'يوم الشهر' : 'Day of Month',
              '${recurringExpense.dayOfMonth}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: isDesktop ? 20 : 18,
          color: settings.secondaryTextColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: settings.secondaryTextColor,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: settings.primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
      ],
    );
  }
}
