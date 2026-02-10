import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class YearlyMonthlyBarChart extends StatelessWidget {
  final Map<int, double> monthlyTotals;
  final SettingsState settings;
  final bool isRTL;

  const YearlyMonthlyBarChart({
    super.key,
    required this.monthlyTotals,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'تفصيل شهري' : 'Monthly Details',
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
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(monthlyTotals),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: _getMaxY(monthlyTotals) / 4,
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
                getDrawingVerticalLine: (value) {
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
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(monthlyTotals),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final monthName = _getMonthName(groupIndex + 1, isRTL);
                    return BarTooltipItem(
                      '$monthName\n${settings.currencySymbol} ${rod.toY.toStringAsFixed(0)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<int, double> monthlyTotals) {
    return List.generate(12, (index) {
      final month = index + 1;
      final amount = monthlyTotals[month] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: settings.isDarkMode ? Colors.blue.shade300 : Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY(Map<int, double> monthlyTotals) {
    final maxValue =
        monthlyTotals.values.isNotEmpty
            ? monthlyTotals.values.reduce((a, b) => a > b ? a : b)
            : 0.0;
    // Prevent zero interval
    return maxValue > 0 ? maxValue * 1.2 : 100000;
  }

  String _getMonthName(int month, bool isRTL) {
    if (isRTL) {
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return months[month - 1];
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
      return months[month - 1];
    }
  }
}
