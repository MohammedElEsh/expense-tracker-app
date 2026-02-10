// Home Feature - Presentation Layer - Home Expense List Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_item.dart';
import 'package:expense_tracker/core/widgets/empty_state_widget.dart';

class HomeExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final bool isRTL;
  final bool isDesktop;
  final bool isTablet;
  final String currencySymbol;
  final Function(Expense) onDelete;
  final Future<void> Function()? onRefresh;

  const HomeExpenseList({
    super.key,
    required this.expenses,
    required this.isRTL,
    required this.isDesktop,
    required this.isTablet,
    required this.currencySymbol,
    required this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Expanded(
        child:
            onRefresh != null
                ? RefreshIndicator(
                  onRefresh: onRefresh!,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: EmptyStateWidget(
                          icon: Icons.receipt_long,
                          title:
                              isRTL
                                  ? 'لا توجد مصروفات لعرضها'
                                  : 'No expenses to display',
                          subtitle:
                              isRTL
                                  ? 'اضغط على زر + لإضافة مصروف جديد'
                                  : 'Tap the + button to add a new expense',
                          actionText: isRTL ? 'إضافة مصروف' : 'Add Expense',
                        ),
                      ),
                    ),
                  ),
                )
                : Center(
                  child: EmptyStateWidget(
                    icon: Icons.receipt_long,
                    title:
                        isRTL
                            ? 'لا توجد مصروفات لعرضها'
                            : 'No expenses to display',
                    subtitle:
                        isRTL
                            ? 'اضغط على زر + لإضافة مصروف جديد'
                            : 'Tap the + button to add a new expense',
                    actionText: isRTL ? 'إضافة مصروف' : 'Add Expense',
                  ),
                ),
      );
    }

    final horizontalPadding =
        isDesktop ? AppSpacing.xxl : (isTablet ? AppSpacing.xl : AppSpacing.md);
    final verticalPadding =
        isDesktop ? AppSpacing.md : (isTablet ? AppSpacing.sm : AppSpacing.xs);
    final itemSpacing =
        isDesktop ? AppSpacing.md : (isTablet ? AppSpacing.sm : AppSpacing.xs);

    return Expanded(
      child:
          onRefresh != null
              ? RefreshIndicator(
                onRefresh: onRefresh!,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      key: ValueKey(expenses[index].id),
                      padding: EdgeInsets.only(bottom: itemSpacing),
                      child: ExpenseItem(
                        expense: expenses[index],
                        currencySymbol: currencySymbol,
                        isRTL: isRTL,
                        onDelete: () => onDelete(expenses[index]),
                      ),
                    );
                  },
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    key: ValueKey(expenses[index].id),
                    padding: EdgeInsets.only(bottom: itemSpacing),
                    child: ExpenseItem(
                      expense: expenses[index],
                      currencySymbol: currencySymbol,
                      isRTL: isRTL,
                      onDelete: () => onDelete(expenses[index]),
                    ),
                  );
                },
              ),
    );
  }
}
