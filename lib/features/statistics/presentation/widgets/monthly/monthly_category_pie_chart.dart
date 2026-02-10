import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class MonthlyCategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final double monthlyTotal;
  final SettingsState settings;
  final bool isRTL;

  const MonthlyCategoryPieChart({
    super.key,
    required this.categoryTotals,
    required this.monthlyTotal,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'الرسم البياني الدائري' : 'Pie Chart',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
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
          child: PieChart(
            PieChartData(
              sections: _buildPieChartSections(categoryTotals, monthlyTotal),
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              startDegreeOffset: 270,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                enabled: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categoryTotals,
    double total,
  ) {
    final isDark = settings.isDarkMode;
    final colors =
        isDark
            ? [
              Colors.blue.shade300,
              Colors.red.shade300,
              Colors.green.shade300,
              Colors.orange.shade300,
              Colors.purple.shade300,
              Colors.teal.shade300,
              Colors.pink.shade300,
              Colors.amber.shade300,
              Colors.indigo.shade300,
              Colors.cyan.shade300,
            ]
            : [
              Colors.blue.shade400,
              Colors.red.shade400,
              Colors.green.shade400,
              Colors.orange.shade400,
              Colors.purple.shade400,
              Colors.teal.shade400,
              Colors.pink.shade400,
              Colors.amber.shade400,
              Colors.indigo.shade400,
              Colors.cyan.shade400,
            ];

    return categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: data.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.55,
        badgeWidget: _buildBadge(data.key, color),
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
