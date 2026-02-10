// Recurring Expense Details - Expense Details Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class RecurringExpenseDetailsCard extends StatelessWidget {
  final RecurringExpense recurringExpense;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const RecurringExpenseDetailsCard({
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
            isRTL ? 'تفاصيل المصروف' : 'Expense Details',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.category,
            isRTL ? 'الفئة' : 'Category',
            recurringExpense.category,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.attach_money,
            isRTL ? 'المبلغ' : 'Amount',
            '${recurringExpense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
          ),
          const SizedBox(height: 12),
          if (recurringExpense.accountName != null &&
              recurringExpense.accountName!.isNotEmpty) ...[
            _buildInfoRow(
              Icons.account_balance_wallet,
              isRTL ? 'الحساب' : 'Account',
              recurringExpense.accountName!,
            ),
            const SizedBox(height: 12),
          ],
          if (recurringExpense.notes.isNotEmpty) ...[
            _buildInfoRow(
              Icons.note,
              isRTL ? 'الملاحظات' : 'Notes',
              recurringExpense.notes,
            ),
            const SizedBox(height: 12),
          ],
          _buildInfoRow(
            Icons.business,
            isRTL ? 'نوع الوضع' : 'App Mode',
            recurringExpense.appMode == AppMode.personal
                ? (isRTL ? 'شخصي' : 'Personal')
                : (isRTL ? 'تجاري' : 'Business'),
          ),
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
