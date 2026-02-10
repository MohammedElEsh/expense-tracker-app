import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/services/permission_service.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/enhanced_statistics_screen.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            return BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                final isRTL = settings.language == 'ar';
                final currentUser = userState.currentUser;

                // Use enhanced statistics for users with advanced permissions
                if (PermissionService.canViewAdvancedReports(currentUser)) {
                  return const EnhancedStatisticsScreen();
                }

                final totalMonth = expenseState.getTotalForMonth(
                  selectedMonth.year,
                  selectedMonth.month,
                );
                final categoryTotals = expenseState.getCategoryTotalsForMonth(
                  selectedMonth.year,
                  selectedMonth.month,
                );

                return Directionality(
                  textDirection:
                      isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(
                        isRTL ? 'الإحصائيات' : 'Statistics',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: settings.primaryColor,
                      foregroundColor:
                          settings.isDarkMode ? Colors.black : Colors.white,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () => _selectMonth(context),
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      padding: EdgeInsets.all(context.spacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Monthly Summary Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                              context.isDesktop ? 24 : 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    settings.isDarkMode
                                        ? [
                                          AppColors.darkSecondary,
                                          const Color(0xFF2E7D32),
                                        ]
                                        : [
                                          AppColors.success,
                                          AppColors.secondary,
                                        ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                context.borderRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: context.isDesktop ? 12 : 8,
                                  offset: Offset(0, context.isDesktop ? 5 : 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isRTL
                                      ? DateFormat(
                                        'MMMM yyyy',
                                        'ar',
                                      ).format(selectedMonth)
                                      : DateFormat(
                                        'MMMM yyyy',
                                      ).format(selectedMonth),
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${settings.currencySymbol}${totalMonth.toStringAsFixed(2)}',
                                  style: AppTypography.displayLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  isRTL
                                      ? 'إجمالي المصروفات الشهرية'
                                      : 'Total Monthly Expenses',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Chart Section
                          if (categoryTotals.isNotEmpty) ...[
                            Text(
                              isRTL
                                  ? 'توزيع المصروفات حسب الفئة'
                                  : 'Expenses by Category',
                              style: AppTypography.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              height: 250,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: AppDecorations.card(context),
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieChartSections(
                                    categoryTotals,
                                    totalMonth,
                                  ),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  startDegreeOffset: 270,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Category List
                          Text(
                            isRTL ? 'تفاصيل الفئات' : 'Category Details',
                            style: AppTypography.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          if (categoryTotals.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xxl),
                              decoration: BoxDecoration(
                                color:
                                    settings.isDarkMode
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.pie_chart_outline,
                                      size: AppSpacing.iconXxl,
                                      color:
                                          settings.isDarkMode
                                              ? AppColors.textDisabledDark
                                              : AppColors.textDisabledLight,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      isRTL
                                          ? 'لا توجد مصروفات لهذا الشهر'
                                          : 'No expenses for this month',
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
                            )
                          else
                            ...categoryTotals.entries.map((entry) {
                              final percentage =
                                  (entry.value / totalMonth * 100);
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: AppDecorations.card(context),
                                child: Row(
                                  children: [
                                    Container(
                                      width: AppSpacing.sm,
                                      height: AppSpacing.sm,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(entry.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        Categories.getDisplayName(
                                          entry.key,
                                          isRTL,
                                        ),
                                        style: AppTypography.titleMedium,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${settings.currencySymbol}${entry.value.toStringAsFixed(2)}',
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color:
                                                    settings.isDarkMode
                                                        ? AppColors
                                                            .textSecondaryDark
                                                        : AppColors
                                                            .textSecondaryLight,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                          const SizedBox(height: AppSpacing.md),

                          // Ad space placeholder
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  settings.isDarkMode
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariantLight,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              border: Border.all(
                                color:
                                    settings.isDarkMode
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isRTL ? 'مساحة إعلانية' : 'Ad Space',
                                style: AppTypography.titleMedium.copyWith(
                                  color:
                                      settings.isDarkMode
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categoryTotals,
    double total,
  ) {
    final colors = AppColors.chartColorsLight;

    return categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': AppColors.chartColorsLight[0],
      'Transportation': AppColors.chartColorsLight[3],
      'Entertainment': AppColors.chartColorsLight[1],
      'Shopping': AppColors.chartColorsLight[2],
      'Bills': AppColors.chartColorsLight[4],
      'Healthcare': AppColors.chartColorsLight[5],
      'Others': AppColors.chartColorsLight[6],
    };
    return colors[category] ?? AppColors.textTertiaryLight;
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }
}
