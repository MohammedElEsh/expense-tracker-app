import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_details_screen.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';
import 'package:expense_tracker/utils/theme_helper.dart';

class ProjectExpensesSection extends StatelessWidget {
  final List<Expense> expenses;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;
  final VoidCallback? onViewAll;

  const ProjectExpensesSection({
    super.key,
    required this.expenses,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
    this.onViewAll,
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
              isRTL ? 'مصروفات المشروع' : 'Project Expenses',
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: settings.primaryTextColor,
              ),
            ),
            if (expenses.isNotEmpty && onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  isRTL ? 'عرض الكل' : 'View All',
                  style: TextStyle(
                    color: settings.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty)
          _buildEmptyExpenses(context)
        else
          _buildExpensesList(context),
      ],
    );
  }

  Widget _buildExpensesList(BuildContext context) {
    final recentExpenses = expenses.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentExpenses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final expense = recentExpenses[index];
        return _buildExpenseCard(context, expense);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(child: ExpenseDetailsScreen(expense: expense)),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  expense.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: isDesktop ? 20 : 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.notes.isNotEmpty ? expense.notes : expense.getDisplayCategoryName(),
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
                    DateFormat('dd MMM yyyy', isRTL ? 'ar' : 'en').format(expense.date),
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: settings.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${expense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      expense.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expense.getDisplayCategoryName(),
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 10,
                      color: _getCategoryColor(expense.category),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExpenses(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 32),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settings.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: isDesktop ? 64 : 48,
            color: context.emptyStateIconColor,
          ),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لا توجد مصروفات' : 'No Expenses',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRTL
                ? 'لم يتم إضافة أي مصروفات لهذا المشروع بعد'
                : 'No expenses have been added to this project yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: settings.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Colors.orange;
      case 'transport':
      case 'مواصلات':
        return Colors.blue;
      case 'shopping':
      case 'تسوق':
        return Colors.purple;
      case 'entertainment':
      case 'ترفيه':
        return Colors.pink;
      case 'health':
      case 'صحة':
        return Colors.red;
      case 'education':
      case 'تعليم':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Icons.restaurant;
      case 'transport':
      case 'مواصلات':
        return Icons.directions_car;
      case 'shopping':
      case 'تسوق':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'ترفيه':
        return Icons.movie;
      case 'health':
      case 'صحة':
        return Icons.local_hospital;
      case 'education':
      case 'تعليم':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
