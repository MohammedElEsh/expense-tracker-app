// Yearly Statistics Tab: data from StatisticsCubit state only.
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_total_card.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_spending_trend_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_monthly_bar_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/yearly/yearly_monthly_breakdown_list.dart';

class YearlyStatisticsTab extends StatelessWidget {
  final StatisticsEntity? statistics;
  final SettingsState settings;
  final bool isRTL;
  final DateTime selectedYear;

  const YearlyStatisticsTab({
    super.key,
    required this.statistics,
    required this.settings,
    required this.isRTL,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    final yearlyTotal = statistics?.totalAmount ?? 0.0;
    final monthlyTotals = Map<int, double>.from(
      statistics?.monthlyBreakdownForYear ?? {},
    );
    for (int m = 1; m <= 12; m++) {
      monthlyTotals.putIfAbsent(m, () => 0.0);
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
