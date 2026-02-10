// Budget Expenses List Card - عرض قائمة المصروفات للميزانية
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/features/budgets/utils/budget_helpers.dart';

class BudgetExpensesListCard extends StatelessWidget {
  final Budget budget;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const BudgetExpensesListCard({
    super.key,
    required this.budget,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, expenseState) {
        // تصفية المصروفات حسب الفئة والشهر
        final categoryExpenses =
            expenseState.expenses.where((expense) {
              return expense.category == budget.category &&
                  expense.date.year == budget.year &&
                  expense.date.month == budget.month;
            }).toList();

        // ترتيب حسب التاريخ (الأحدث أولاً)
        categoryExpenses.sort((a, b) => b.date.compareTo(a.date));

        return Container(
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
              _buildHeader(categoryExpenses.length),
              const SizedBox(height: 16),

              if (categoryExpenses.isEmpty)
                _buildEmptyState()
              else
                ...categoryExpenses.map(
                  (expense) => _buildExpenseItem(expense),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int expenseCount) {
    final categoryColor = BudgetHelpers.getCategoryColor(budget.category);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isRTL ? 'المصروفات' : 'Expenses',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$expenseCount',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: isDesktop ? 64 : 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isRTL
                  ? 'لا توجد مصروفات في هذه الفئة'
                  : 'No expenses in this category',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: settings.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final categoryColor = BudgetHelpers.getCategoryColor(budget.category);
    final categoryIcon = BudgetHelpers.getCategoryIcon(budget.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color:
            settings.isDarkMode
                ? Colors.grey.shade800.withValues(alpha: 0.3)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              settings.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: isDesktop ? 24 : 20,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.notes.isEmpty
                      ? Categories.getDisplayName(expense.category, isRTL)
                      : expense.notes,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: settings.primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                    isRTL ? 'ar' : 'en',
                  ).format(expense.date),
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: settings.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${expense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color:
                  settings.isDarkMode
                      ? Colors.red.shade300
                      : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
