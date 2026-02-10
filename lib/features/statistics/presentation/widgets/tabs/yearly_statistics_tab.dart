// ✅ Yearly Statistics Tab - Refactored & Clean
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_total_card.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_spending_trend_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_monthly_bar_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_monthly_breakdown_list.dart';

class YearlyStatisticsTab extends StatelessWidget {
  final ExpenseState expenseState;
  final SettingsState settings;
  final bool isRTL;
  final DateTime selectedYear;

  const YearlyStatisticsTab({
    super.key,
    required this.expenseState,
    required this.settings,
    required this.isRTL,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate yearly total
    final yearExpenses =
        expenseState.allExpenses.where((expense) {
          return expense.date.year == selectedYear.year;
        }).toList();

    final yearlyTotal = yearExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calculate monthly breakdown
    final Map<int, double> monthlyTotals = {};
    for (int month = 1; month <= 12; month++) {
      monthlyTotals[month] = 0.0;
    }

    for (final expense in yearExpenses) {
      monthlyTotals[expense.date.month] =
          (monthlyTotals[expense.date.month] ?? 0) + expense.amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Yearly Total Card
          YearlyTotalCard(
            year: selectedYear.year,
            total: yearlyTotal,
            settings: settings,
            isRTL: isRTL,
          ),

          const SizedBox(height: 24),

          // 2. Yearly Spending Trend Chart
          YearlySpendingTrendChart(
            monthlyTotals: monthlyTotals,
            settings: settings,
            isRTL: isRTL,
          ),

          const SizedBox(height: 32),

          // 3. Monthly Details Bar Chart
          YearlyMonthlyBarChart(
            monthlyTotals: monthlyTotals,
            settings: settings,
            isRTL: isRTL,
          ),

          const SizedBox(height: 32),

          // 4. Monthly Breakdown List
          YearlyMonthlyBreakdownList(
            monthlyTotals: monthlyTotals,
            yearlyTotal: yearlyTotal,
            settings: settings,
            isRTL: isRTL,
          ),
        ],
      ),
    );
  }
}
