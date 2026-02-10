import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class MonthlySpendingTrendChart extends StatelessWidget {
  final List<double> data;
  final SettingsState settings;
  final bool isRTL;
  final DateTime selectedMonth;

  const MonthlySpendingTrendChart({
    super.key,
    required this.data,
    required this.settings,
    required this.isRTL,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL
              ? 'اتجاه الإنفاق (آخر 6 أشهر)'
              : 'Spending Trend (Last 6 Months)',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: settings.isDarkMode ? Colors.grey.shade900 : Colors.white,
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
              maxY: _getMaxY(data),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getMaxY(data) / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color:
                        settings.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
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
                      final monthIndex =
                          selectedMonth.month - 5 + value.toInt();
                      final month =
                          monthIndex > 0 ? monthIndex : 12 + monthIndex;
                      return Text(
                        _getShortMonthName(month, isRTL),
                        style: TextStyle(
                          fontSize: 11,
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
              lineBarsData: [
                LineChartBarData(
                  spots:
                      data
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                  isCurved: true,
                  color:
                      settings.isDarkMode
                          ? Colors.green.shade400
                          : Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color:
                            settings.isDarkMode
                                ? Colors.grey.shade900
                                : Colors.white,
                        strokeWidth: 2,
                        strokeColor:
                            settings.isDarkMode
                                ? Colors.green.shade400
                                : Colors.green,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        settings.isDarkMode
                            ? Colors.green.shade800.withValues(alpha: 0.2)
                            : Colors.green.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final monthIndex =
                          selectedMonth.month - 5 + spot.x.toInt();
                      final month =
                          monthIndex > 0 ? monthIndex : 12 + monthIndex;
                      final monthName = _getShortMonthName(month, isRTL);
                      return LineTooltipItem(
                        '$monthName\n${settings.currencySymbol} ${spot.y.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxY(List<double> data) {
    if (data.isEmpty) return 100000;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    // Prevent zero interval
    return maxValue > 0 ? maxValue * 1.2 : 100000;
  }

  String _getShortMonthName(int month, bool isRTL) {
    if (isRTL) {
      const months = [
        'ينا',
        'فبر',
        'مار',
        'أبر',
        'ماي',
        'يون',
        'يول',
        'أغس',
        'سبت',
        'أكت',
        'نوف',
        'ديس',
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
