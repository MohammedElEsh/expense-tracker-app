// ✅ Weekly Statistics Tab - Extracted from Enhanced Statistics Screen
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class WeeklyStatisticsTab extends StatelessWidget {
  final ExpenseState expenseState;
  final SettingsState settings;
  final bool isRTL;

  const WeeklyStatisticsTab({
    super.key,
    required this.expenseState,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate weekly total
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekExpenses =
        expenseState.allExpenses.where((expense) {
          return expense.date.isAfter(startOfWeek) ||
              expense.date.isAtSameMomentAs(startOfWeek);
        }).toList();

    final weeklyTotal = weekExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    settings.isDarkMode
                        ? [Colors.blue.shade700, Colors.blue.shade800]
                        : [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      settings.isDarkMode
                          ? Colors.blue.shade900.withValues(alpha: 0.5)
                          : Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'إجمالي الأسبوع' : 'Weekly Total',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${settings.currencySymbol} ${weeklyTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${weekExpenses.length} ${isRTL ? 'مصروف' : 'expenses'}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Line Chart - Daily expenses for the week
          Text(
            isRTL ? 'نفقات الأسبوع' : 'Weekly Expenses',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    settings.isDarkMode
                        ? [Colors.grey.shade900, Colors.grey.shade800]
                        : [
                          Colors.blue.shade50.withValues(alpha: 0.3),
                          Colors.white,
                        ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: _getMaxY(weekExpenses, startOfWeek),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY(weekExpenses, startOfWeek) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                          settings.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          '${settings.currencySymbol} ${(value / 1000).toStringAsFixed(1)}K',
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return _buildDayTitle(value.toInt(), isRTL);
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
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildLineChartSpots(weekExpenses, startOfWeek),
                    isCurved: true,
                    color:
                        settings.isDarkMode
                            ? Colors.blue.shade300
                            : Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color:
                              settings.isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.white,
                          strokeWidth: 3,
                          strokeColor:
                              settings.isDarkMode
                                  ? Colors.blue.shade300
                                  : Colors.blue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors:
                            settings.isDarkMode
                                ? [
                                  Colors.blue.shade800.withValues(alpha: 0.3),
                                  Colors.blue.shade900.withValues(alpha: 0.1),
                                ]
                                : [
                                  Colors.blue.withValues(alpha: 0.2),
                                  Colors.blue.withValues(alpha: 0.05),
                                ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dayName = _getDayName(spot.x.toInt(), isRTL);
                        return LineTooltipItem(
                          '$dayName\n${settings.currencySymbol} ${spot.y.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Daily Breakdown Section
          Text(
            isRTL ? 'تفاصيل المصروفات اليومية' : 'Daily Expense Details',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Show message if no expenses
          if (weekExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      isRTL
                          ? 'لا توجد نفقات هذا الأسبوع'
                          : 'No expenses this week',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            // List of expenses
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weekExpenses.length,
              itemBuilder: (context, index) {
                final expense = weekExpenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      child: const Icon(Icons.attach_money, color: Colors.blue),
                    ),
                    title: Text(
                      expense.notes.isEmpty ? expense.category : expense.notes,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                    ),
                    trailing: Text(
                      '${settings.currencySymbol} ${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Build line chart spots for each day of the week
  List<FlSpot> _buildLineChartSpots(
    List<dynamic> weekExpenses,
    DateTime startOfWeek,
  ) {
    final Map<int, double> dailyTotals = {};

    // Initialize all days with 0
    for (int i = 0; i < 7; i++) {
      dailyTotals[i] = 0.0;
    }

    // Calculate totals for each day
    for (final expense in weekExpenses) {
      final dayIndex = expense.date.difference(startOfWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + expense.amount;
      }
    }

    // Create spots for line chart
    return List.generate(7, (index) {
      final value = dailyTotals[index] ?? 0.0;
      return FlSpot(index.toDouble(), value);
    });
  }

  // Get maximum Y value for chart scaling
  double _getMaxY(List<dynamic> weekExpenses, DateTime startOfWeek) {
    final Map<int, double> dailyTotals = {};

    for (final expense in weekExpenses) {
      final dayIndex = expense.date.difference(startOfWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + expense.amount;
      }
    }

    final maxValue =
        dailyTotals.values.isNotEmpty
            ? dailyTotals.values.reduce((a, b) => a > b ? a : b)
            : 0.0;

    // Prevent zero interval - return minimum value if no data
    return maxValue > 0 ? maxValue * 1.2 : 100000;
  }

  // Build day title widget (short names)
  Widget _buildDayTitle(int dayIndex, bool isRTL) {
    final days =
        isRTL
            ? ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد']
            : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (dayIndex < 0 || dayIndex >= days.length) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        days[dayIndex],
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Get full day name for tooltip
  String _getDayName(int dayIndex, bool isRTL) {
    final days =
        isRTL
            ? [
              'الإثنين',
              'الثلاثاء',
              'الأربعاء',
              'الخميس',
              'الجمعة',
              'السبت',
              'الأحد',
            ]
            : [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ];

    if (dayIndex < 0 || dayIndex >= days.length) {
      return '';
    }

    return days[dayIndex];
  }
}
