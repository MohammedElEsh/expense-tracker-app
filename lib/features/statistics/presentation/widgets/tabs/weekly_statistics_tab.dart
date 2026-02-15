// Weekly Statistics Tab: data from StatisticsCubit state only.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class WeeklyStatisticsTab extends StatelessWidget {
  final StatisticsEntity? statistics;
  final SettingsState settings;
  final bool isRTL;

  const WeeklyStatisticsTab({
    super.key,
    required this.statistics,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyTotal = statistics?.totalAmount ?? 0.0;
    final expenseCount = statistics?.expenseCount ?? 0;
    final dailyTotals = statistics?.dailyTotalsForWeek ?? List.filled(7, 0.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  '$expenseCount ${isRTL ? 'مصروف' : 'expenses'}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                maxY: _maxY(dailyTotals),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY(dailyTotals) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                          settings.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                      strokeWidth: 1,
                      dashArray: const [5, 5],
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
                    spots: List.generate(
                      7,
                      (i) => FlSpot(i.toDouble(), dailyTotals.length > i ? dailyTotals[i] : 0.0),
                    ),
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
          Text(
            isRTL ? 'تفاصيل المصروفات اليومية' : 'Daily Expense Details',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (expenseCount == 0)
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
            ...List.generate(7, (i) {
              final dayNames = isRTL
                  ? ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد']
                  : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
              final value = dailyTotals.length > i ? dailyTotals[i] : 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(dayNames[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(
                    '${settings.currencySymbol} ${value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  double _maxY(List<double> dailyTotals) {
    if (dailyTotals.isEmpty) return 100.0;
    final m = dailyTotals.reduce((a, b) => a > b ? a : b);
    return m > 0 ? m * 1.2 : 100.0;
  }

  Widget _buildDayTitle(int dayIndex, bool isRTL) {
    final days = isRTL
        ? ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (dayIndex < 0 || dayIndex >= days.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        days[dayIndex],
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }

  String _getDayName(int dayIndex, bool isRTL) {
    final days = isRTL
        ? ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (dayIndex < 0 || dayIndex >= days.length) return '';
    return days[dayIndex];
  }
}
