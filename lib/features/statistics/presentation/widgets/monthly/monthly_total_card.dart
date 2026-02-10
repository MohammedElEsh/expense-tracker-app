import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class MonthlyTotalCard extends StatelessWidget {
  final double total;
  final int expenseCount;
  final SettingsState settings;
  final bool isRTL;

  const MonthlyTotalCard({
    super.key,
    required this.total,
    required this.expenseCount,
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
                  ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
                  : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.green.shade900.withValues(alpha: 0.5)
                    : Colors.green.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isRTL ? 'إجمالي الشهر' : 'Month Total',
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
          const SizedBox(height: 8),
          Text(
            '$expenseCount ${isRTL ? 'مصروف' : 'expenses'}',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
