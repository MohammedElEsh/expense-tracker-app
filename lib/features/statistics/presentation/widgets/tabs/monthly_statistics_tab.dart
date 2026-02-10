// ✅ Monthly Statistics Tab - Refactored & Clean
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_total_card.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_budget_message_card.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_spending_trend_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_category_pie_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_category_breakdown_list.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

class MonthlyStatisticsTab extends StatelessWidget {
  final ExpenseState expenseState;
  final SettingsState settings;
  final bool isRTL;
  final DateTime selectedMonth;

  const MonthlyStatisticsTab({
    super.key,
    required this.expenseState,
    required this.settings,
    required this.isRTL,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate monthly total
    final monthExpenses =
        expenseState.allExpenses.where((expense) {
          return expense.date.year == selectedMonth.year &&
              expense.date.month == selectedMonth.month;
        }).toList();

    final monthlyTotal = monthExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (final expense in monthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Calculate last 6 months spending trend
    final List<double> last6MonthsData = _calculateLast6MonthsData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Monthly Total Card
          MonthlyTotalCard(
            total: monthlyTotal,
            expenseCount: monthExpenses.length,
            settings: settings,
            isRTL: isRTL,
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Budget Message Card
          MonthlyBudgetMessageCard(selectedMonth: selectedMonth, isRTL: isRTL),

          const SizedBox(height: AppSpacing.xl),

          // 3. Spending Trend Chart (Last 6 Months)
          MonthlySpendingTrendChart(
            data: last6MonthsData,
            settings: settings,
            isRTL: isRTL,
            selectedMonth: selectedMonth,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // 4. Category Distribution
          if (categoryTotals.isNotEmpty) ...[
            MonthlyCategoryPieChart(
              categoryTotals: categoryTotals,
              monthlyTotal: monthlyTotal,
              settings: settings,
              isRTL: isRTL,
            ),
            const SizedBox(height: AppSpacing.xxl),
            MonthlyCategoryBreakdownList(
              categoryTotals: categoryTotals,
              monthlyTotal: monthlyTotal,
              settings: settings,
              isRTL: isRTL,
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 64,
                      color:
                          settings.isDarkMode
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabledLight,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      isRTL
                          ? 'لا توجد نفقات هذا الشهر'
                          : 'No expenses this month',
                      style: AppTypography.bodyLarge.copyWith(
                        color:
                            settings.isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper: Calculate Last 6 Months Data
  List<double> _calculateLast6MonthsData() {
    final List<double> data = [];
    for (int i = 5; i >= 0; i--) {
      final targetMonth = DateTime(selectedMonth.year, selectedMonth.month - i);
      final monthExpenses = expenseState.allExpenses.where((expense) {
        return expense.date.year == targetMonth.year &&
            expense.date.month == targetMonth.month;
      });
      final total = monthExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );
      data.add(total);
    }
    return data;
  }
}
