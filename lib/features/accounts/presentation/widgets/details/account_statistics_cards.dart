// Account Details - Statistics Cards Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class AccountStatisticsCards extends StatelessWidget {
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;
  final double totalExpenses;
  final double monthlyExpenses;
  final int transactionCount;

  const AccountStatisticsCards({
    super.key,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
    required this.totalExpenses,
    required this.monthlyExpenses,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : 1.2,
      children: [
        _buildStatCard(
          Icons.receipt_long,
          isRTL ? 'إجمالي المعاملات' : 'Total Transactions',
          transactionCount.toString(),
          Colors.blue,
        ),
        _buildStatCard(
          Icons.trending_down,
          isRTL ? 'إجمالي المصروفات' : 'Total Expenses',
          '${totalExpenses.toStringAsFixed(2)} ${settings.currencySymbol}',
          Colors.red,
        ),
        _buildStatCard(
          Icons.calendar_month,
          isRTL ? 'مصروفات الشهر' : 'Monthly Expenses',
          '${monthlyExpenses.toStringAsFixed(2)} ${settings.currencySymbol}',
          Colors.orange,
        ),
        _buildStatCard(
          Icons.analytics,
          isRTL ? 'متوسط المعاملة' : 'Average Transaction',
          transactionCount > 0
              ? '${(totalExpenses / transactionCount).toStringAsFixed(2)} ${settings.currencySymbol}'
              : '0 ${settings.currencySymbol}',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settings.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isDesktop ? 24 : 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: settings.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: settings.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
