import 'package:flutter/material.dart';

/// Shows budget message from StatisticsCubit state (budgetCountForMonth).
/// No direct Cubit/service access.
class MonthlyBudgetMessageCard extends StatelessWidget {
  final int budgetCountForMonth;
  final bool isRTL;

  const MonthlyBudgetMessageCard({
    super.key,
    required this.budgetCountForMonth,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final hasBudgets = budgetCountForMonth > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark
                    ? (hasBudgets
                        ? Colors.blue.shade900.withValues(alpha: 0.3)
                        : Colors.orange.shade900.withValues(alpha: 0.3))
                    : (hasBudgets
                        ? Colors.blue.shade50
                        : Colors.orange.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDark
                      ? (hasBudgets
                          ? Colors.blue.shade700
                          : Colors.orange.shade700)
                      : (hasBudgets
                          ? Colors.blue.shade200
                          : Colors.orange.shade200),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasBudgets ? Icons.check_circle : Icons.folder_open,
                color:
                    isDark
                        ? (hasBudgets
                            ? Colors.blue.shade300
                            : Colors.orange.shade300)
                        : (hasBudgets
                            ? Colors.blue.shade700
                            : Colors.orange.shade700),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasBudgets
                      ? (isRTL
                          ? 'تم تعيين $budgetCountForMonth ميزانية لهذا الشهر'
                          : '$budgetCountForMonth budget(s) set for this month')
                      : (isRTL
                          ? 'لا توجد ميزانيات محددة لهذا الشهر'
                          : 'No specific budgets for this month'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark
                            ? (hasBudgets
                                ? Colors.blue.shade200
                                : Colors.orange.shade200)
                            : (hasBudgets
                                ? Colors.blue.shade900
                                : Colors.orange.shade900),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
