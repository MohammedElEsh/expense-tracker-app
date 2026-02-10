import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final SettingsState settings;
  final bool isRTL;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;
    final isOverBudget = totalSpent > totalBudget;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isOverBudget
                  ? [Colors.red, Colors.red.shade700]
                  : [Colors.blue, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? Colors.red : Colors.blue).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'إجمالي الميزانية' : 'Total Budget',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalBudget.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isRTL ? 'المتبقي' : 'Remaining',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${remaining.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: TextStyle(
                      color: isOverBudget ? Colors.red.shade200 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.red.shade200 : Colors.white,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% ${isRTL ? 'مستخدم' : 'Used'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${totalSpent.toStringAsFixed(2)} ${settings.currencySymbol}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
