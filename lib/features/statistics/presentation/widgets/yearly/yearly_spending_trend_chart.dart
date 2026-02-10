import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class YearlySpendingTrendChart extends StatelessWidget {
  final Map<int, double> monthlyTotals;
  final SettingsState settings;
  final bool isRTL;

  const YearlySpendingTrendChart({
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
          isRTL ? 'اتجاه الإنفاق السنوي' : 'Annual Spending Trend',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  settings.isDarkMode
                      ? [Colors.grey.shade900, Colors.grey.shade800]
                      : [
                        Colors.orange.shade50.withValues(alpha: 0.3),
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
              maxY: _getMaxY(monthlyTotals),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
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
                      return _buildMonthTitle(value.toInt(), isRTL);
                    },
                    interval: 1,
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
                  spots: _buildLineChartSpots(monthlyTotals),
                  isCurved: true,
                  color:
                      settings.isDarkMode
                          ? Colors.orange.shade300
                          : Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color:
                            settings.isDarkMode
                                ? Colors.orange.shade300
                                : Colors.orange,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors:
                          settings.isDarkMode
                              ? [
                                Colors.orange.shade800.withValues(alpha: 0.3),
                                Colors.orange.shade900.withValues(alpha: 0.1),
                              ]
                              : [
                                Colors.orange.withValues(alpha: 0.3),
                                Colors.orange.withValues(alpha: 0.05),
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
                      final monthName = _getMonthName(
                        spot.x.toInt() + 1,
                        isRTL,
                      );
                      return LineTooltipItem(
                        '$monthName\n${settings.currencySymbol} ${spot.y.toStringAsFixed(0)}',
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
      ],
    );
  }

  List<FlSpot> _buildLineChartSpots(Map<int, double> monthlyTotals) {
    return List.generate(12, (index) {
      final month = index + 1;
      final amount = monthlyTotals[month] ?? 0.0;
      return FlSpot(index.toDouble(), amount);
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

  Widget _buildMonthTitle(int monthIndex, bool isRTL) {
    if (monthIndex < 0 || monthIndex >= 12) {
      return const SizedBox.shrink();
    }

    final monthNames =
        isRTL
            ? [
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
            ]
            : [
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

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        monthNames[monthIndex],
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
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
