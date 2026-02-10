// Budget Progress Card - عرض التقدم في الميزانية
import 'package:flutter/material.dart';

import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;
    final isOverBudget = spent > budget.limit;
    final isNearLimit = percentage >= 80 && !isOverBudget;

    final statusColor =
        isOverBudget
            ? Colors.red
            : isNearLimit
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: settings.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isRTL ? 'التقدم' : 'Progress',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Progress Circle
          SizedBox(
            height: isDesktop ? 200 : 150,
            width: isDesktop ? 200 : 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: isDesktop ? 200 : 150,
                  width: isDesktop ? 200 : 150,
                  child: CircularProgressIndicator(
                    value: percentage / 100 > 1 ? 1 : percentage / 100,
                    strokeWidth: isDesktop ? 16 : 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isDesktop ? 36 : 28,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      isRTL ? 'مستخدم' : 'Used',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: settings.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              isOverBudget
                  ? (isRTL ? 'تجاوزت الميزانية!' : 'Over Budget!')
                  : isNearLimit
                  ? (isRTL ? 'قريب من الحد' : 'Near Limit')
                  : (isRTL ? 'ضمن الميزانية' : 'Within Budget'),
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
