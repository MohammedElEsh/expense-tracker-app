// Account Details - Transactions Section Widget
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
class AccountTransactionsSection extends StatelessWidget {
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;
  final List<Expense> expenses;

  const AccountTransactionsSection({
    super.key,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRTL ? 'المعاملات الأخيرة' : 'Recent Transactions',
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: settings.primaryTextColor,
              ),
            ),
            if (expenses.isNotEmpty)
              TextButton(
                onPressed: () => _showAllTransactions(context),
                child: Text(isRTL ? 'عرض الكل' : 'View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: isDesktop ? 80 : 64,
                    color:
                        settings.isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRTL ? 'لا توجد معاملات' : 'No transactions yet',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      color: settings.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length > 5 ? 5 : expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _buildTransactionCard(context, expense);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, Expense expense) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settings.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 12 : 8,
        ),
        leading: Container(
          width: isDesktop ? 48 : 40,
          height: isDesktop ? 48 : 40,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_downward,
            color: Colors.red,
            size: isDesktop ? 24 : 20,
          ),
        ),
        title: Text(
          expense.category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isDesktop ? 16 : 14,
            color: settings.primaryTextColor,
          ),
        ),
        subtitle: Text(
          DateFormat(
            'dd MMM yyyy, HH:mm',
            isRTL ? 'ar' : 'en',
          ).format(expense.date),
          style: TextStyle(
            fontSize: isDesktop ? 13 : 12,
            color: settings.secondaryTextColor,
          ),
        ),
        trailing: Text(
          '-${expense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 16 : 14,
            color: Colors.red,
          ),
        ),
        onTap: () => _navigateToExpenseDetails(context, expense),
      ),
    );
  }

  void _navigateToExpenseDetails(BuildContext context, Expense expense) {
    context.push(AppRoutes.expenseDetails, extra: expense);
  }

  void _showAllTransactions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'جميع المعاملات' : 'All Transactions'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return _buildTransactionCard(context, expense);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(isRTL ? 'إغلاق' : 'Close'),
              ),
            ],
          ),
    );
  }
}
