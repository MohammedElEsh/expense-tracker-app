import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class YearlyTotalCard extends StatelessWidget {
  final int year;
  final double total;
  final SettingsState settings;
  final bool isRTL;

  const YearlyTotalCard({
    super.key,
    required this.year,
    required this.total,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settings.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.orange.shade700, Colors.deepOrange.shade800]
                  : [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.orange.shade900.withValues(alpha: 0.5)
                    : Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isRTL ? 'إجمالي السنة $year' : 'Year Total $year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${settings.currencySymbol} ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
