// Monthly Statistics Tab: data from StatisticsCubit state only (no business logic).
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_total_card.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_budget_message_card.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_spending_trend_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_category_pie_chart.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/monthly/monthly_category_breakdown_list.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

class MonthlyStatisticsTab extends StatelessWidget {
  final StatisticsEntity? statistics;
  final SettingsState settings;
  final bool isRTL;
  final DateTime selectedMonth;

  const MonthlyStatisticsTab({
    super.key,
    required this.statistics,
    required this.settings,
    required this.isRTL,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyTotal = statistics?.totalAmount ?? 0.0;
    final expenseCount = statistics?.expenseCount ?? 0;
    final categoryTotals = statistics?.categoryTotals ?? <String, double>{};
    final last6MonthsData = statistics?.last6MonthsTotals ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthlyTotalCard(
            total: monthlyTotal,
            expenseCount: expenseCount,
            settings: settings,
            isRTL: isRTL,
          ),
          const SizedBox(height: AppSpacing.md),
          MonthlyBudgetMessageCard(
            budgetCountForMonth: statistics?.budgetCountForMonth ?? 0,
            isRTL: isRTL,
          ),
          const SizedBox(height: AppSpacing.xl),
          MonthlySpendingTrendChart(
            data: last6MonthsData,
            settings: settings,
            isRTL: isRTL,
            selectedMonth: selectedMonth,
          ),
          const SizedBox(height: AppSpacing.xxl),
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
}
