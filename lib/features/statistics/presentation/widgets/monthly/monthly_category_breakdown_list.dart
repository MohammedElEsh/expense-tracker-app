import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class MonthlyCategoryBreakdownList extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final double monthlyTotal;
  final SettingsState settings;
  final bool isRTL;

  const MonthlyCategoryBreakdownList({
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
          isRTL ? 'التوزيع حسب الفئة' : 'Category Breakdown',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...categoryTotals.entries.map((entry) {
          final percentage =
              monthlyTotal > 0 ? (entry.value / monthlyTotal * 100) : 0.0;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${settings.currencySymbol} ${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
