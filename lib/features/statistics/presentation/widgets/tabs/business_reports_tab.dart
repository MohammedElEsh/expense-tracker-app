// ✅ Business Reports Tab - Extracted from Enhanced Statistics Screen
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class BusinessReportsTab extends StatelessWidget {
  final ExpenseState expenseState;
  final SettingsState settings;
  final bool isRTL;

  const BusinessReportsTab({
    super.key,
    required this.expenseState,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final expenses = expenseState.allExpenses;

    // Calculate this month's data
    final now = DateTime.now();
    final thisMonthExpenses =
        expenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();

    final thisMonthTotal = thisMonthExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calculate last month's data for comparison
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthExpenses =
        expenses.where((expense) {
          return expense.date.year == lastMonth.year &&
              expense.date.month == lastMonth.month;
        }).toList();

    final lastMonthTotal = lastMonthExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calculate change percentage
    final changePercentage =
        lastMonthTotal > 0
            ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
            : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Comparison Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigo.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'هذا الشهر' : 'This Month',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${settings.currencySymbol} ${thisMonthTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      changePercentage >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: changePercentage >= 0 ? Colors.red : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${changePercentage.abs().toStringAsFixed(1)}% ${isRTL ? (changePercentage >= 0 ? 'زيادة' : 'انخفاض') : (changePercentage >= 0 ? 'increase' : 'decrease')}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            changePercentage >= 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Monthly Comparison Bar Chart
          if (expenses.isNotEmpty) ...[
            Text(
              isRTL ? 'المقارنة الشهرية' : 'Monthly Comparison',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    settings.isDarkMode ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    settings.isDarkMode
                        ? Border.all(color: Colors.grey.shade800)
                        : null,
                boxShadow: [
                  BoxShadow(
                    color:
                        settings.isDarkMode
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(expenses, now),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final monthName = _getMonthName(
                          now.month - 5 + groupIndex,
                          isRTL,
                        );
                        return BarTooltipItem(
                          '$monthName\n${settings.currencySymbol} ${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return _buildMonthTitle(
                            now.month - 5 + value.toInt(),
                            isRTL,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  settings.isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: _buildBarGroups(expenses, now),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Summary Stats
          Text(
            isRTL ? 'ملخص الأداء' : 'Performance Summary',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _SummaryCard(
                title: isRTL ? 'هذا الشهر' : 'This Month',
                value: '${thisMonthExpenses.length}',
                subtitle: isRTL ? 'مصروف' : 'expenses',
                color: Colors.blue,
              ),
              _SummaryCard(
                title: isRTL ? 'الشهر الماضي' : 'Last Month',
                value: '${lastMonthExpenses.length}',
                subtitle: isRTL ? 'مصروف' : 'expenses',
                color: Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            isRTL ? 'إجراءات سريعة' : 'Quick Actions',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _ActionButton(
            icon: Icons.file_download,
            label: isRTL ? 'تصدير التقرير' : 'Export Report',
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isRTL
                        ? 'قريباً: تصدير التقرير'
                        : 'Coming soon: Export Report',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _ActionButton(
            icon: Icons.print,
            label: isRTL ? 'طباعة التقرير' : 'Print Report',
            color: Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isRTL
                        ? 'قريباً: طباعة التقرير'
                        : 'Coming soon: Print Report',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Build bar groups for last 6 months
  List<BarChartGroupData> _buildBarGroups(
    List<dynamic> expenses,
    DateTime now,
  ) {
    final Map<int, double> monthlyTotals = {};

    // Calculate totals for last 6 months
    for (int i = 0; i < 6; i++) {
      final targetMonth = DateTime(now.year, now.month - (5 - i));
      final monthExpenses = expenses.where((expense) {
        return expense.date.year == targetMonth.year &&
            expense.date.month == targetMonth.month;
      });
      monthlyTotals[i] = monthExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );
    }

    return List.generate(6, (index) {
      final value = monthlyTotals[index] ?? 0.0;
      final isCurrentMonth = index == 5;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 28,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: LinearGradient(
              colors:
                  settings.isDarkMode
                      ? (isCurrentMonth
                          ? [Colors.indigo.shade400, Colors.indigo.shade300]
                          : [Colors.indigo.shade500, Colors.indigo.shade400])
                      : (isCurrentMonth
                          ? [Colors.indigo.shade700, Colors.indigo.shade500]
                          : [Colors.indigo.shade400, Colors.indigo.shade200]),
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }

  // Get maximum Y value
  double _getMaxY(List<dynamic> expenses, DateTime now) {
    double maxValue = 0.0;

    for (int i = 0; i < 6; i++) {
      final targetMonth = DateTime(now.year, now.month - (5 - i));
      final monthExpenses = expenses.where((expense) {
        return expense.date.year == targetMonth.year &&
            expense.date.month == targetMonth.month;
      });
      final total = monthExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );
      if (total > maxValue) maxValue = total;
    }

    // Prevent zero interval
    return maxValue > 0 ? maxValue * 1.2 : 100000;
  }

  // Build month title
  Widget _buildMonthTitle(int month, bool isRTL) {
    // Normalize month to 1-12 range
    int normalizedMonth = month % 12;
    if (normalizedMonth == 0) normalizedMonth = 12;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _getMonthName(normalizedMonth, isRTL),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Get month name
  String _getMonthName(int month, bool isRTL) {
    int normalizedMonth = month % 12;
    if (normalizedMonth == 0) normalizedMonth = 12;

    if (isRTL) {
      const months = [
        'ي',
        'ف',
        'م',
        'أ',
        'م',
        'ي',
        'ي',
        'أ',
        'س',
        'أ',
        'ن',
        'د',
      ];
      return months[normalizedMonth - 1];
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return months[normalizedMonth - 1];
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
