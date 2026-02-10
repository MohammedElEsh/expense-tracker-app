// Budget Financial Details Card - عرض التفاصيل المالية للميزانية
import 'package:flutter/material.dart';

import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class BudgetFinancialDetailsCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const BudgetFinancialDetailsCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget.limit - spent;
    final isOverBudget = spent > budget.limit;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'التفاصيل المالية' : 'Financial Details',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),

          _buildDetailRow(
            Icons.account_balance_wallet,
            isRTL ? 'الميزانية المحددة' : 'Budget Limit',
            '${budget.limit.toStringAsFixed(2)} ${settings.currencySymbol}',
            settings.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
          ),
          const Divider(height: 24),

          _buildDetailRow(
            Icons.trending_up,
            isRTL ? 'المبلغ المُنفق' : 'Amount Spent',
            '${spent.toStringAsFixed(2)} ${settings.currencySymbol}',
            settings.isDarkMode
                ? Colors.orange.shade300
                : Colors.orange.shade700,
          ),
          const Divider(height: 24),

          _buildDetailRow(
            isOverBudget ? Icons.warning : Icons.savings,
            isRTL ? 'المتبقي' : 'Remaining',
            '${remaining.abs().toStringAsFixed(2)} ${settings.currencySymbol}',
            isOverBudget
                ? (settings.isDarkMode
                    ? Colors.red.shade300
                    : Colors.red.shade700)
                : (settings.isDarkMode
                    ? Colors.green.shade300
                    : Colors.green.shade700),
          ),

          if (isOverBudget) ...[
            const Divider(height: 24),
            _buildDetailRow(
              Icons.error_outline,
              isRTL ? 'تجاوز الميزانية' : 'Over Budget',
              '${budget.overAmount.toStringAsFixed(2)} ${settings.currencySymbol}',
              settings.isDarkMode ? Colors.red.shade300 : Colors.red.shade700,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: isDesktop ? 24 : 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: settings.secondaryTextColor,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
