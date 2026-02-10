import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/services/permission_service.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/enhanced_statistics_screen_refactored.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, expenseState) {
            return BlocBuilder<UserBloc, UserState>(
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                                          const Color(0xFF388E3C),
                                          const Color(0xFF2E7D32),
                                        ]
                                        : [Colors.green, Colors.greenAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                context.borderRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: settings.successColor.withValues(
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${settings.currencySymbol}${totalMonth.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isRTL
                                      ? 'إجمالي المصروفات الشهرية'
                                      : 'Total Monthly Expenses',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Chart Section
                          if (categoryTotals.isNotEmpty) ...[
                            Text(
                              isRTL
                                  ? 'توزيع المصروفات حسب الفئة'
                                  : 'Expenses by Category',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 250,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
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
                            const SizedBox(height: 16),
                          ],

                          // Category List
                          Text(
                            isRTL ? 'تفاصيل الفئات' : 'Category Details',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (categoryTotals.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.pie_chart_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isRTL
                                          ? 'لا توجد مصروفات لهذا الشهر'
                                          : 'No expenses for this month',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
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
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(entry.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        Categories.getDisplayName(entry.key, isRTL),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${settings.currencySymbol}${entry.value.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                          const SizedBox(height: 16),

                          // Ad space placeholder
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                isRTL ? 'مساحة إعلانية' : 'Ad Space',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    return categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.blue,
      'Transportation': Colors.red,
      'Entertainment': Colors.green,
      'Shopping': Colors.orange,
      'Bills': Colors.purple,
      'Healthcare': Colors.teal,
      'Others': Colors.pink,
    };
    return colors[category] ?? Colors.grey;
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
