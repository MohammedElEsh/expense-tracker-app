// Accounts - Summary Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';

class AccountsSummaryCard extends StatelessWidget {
  final AccountState accountState;
  final bool isRTL;

  const AccountsSummaryCard({
    super.key,
    required this.accountState,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return Card(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      elevation: context.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.borderRadius),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).primaryColor,
                    size: isDesktop ? 40 : 32,
                  ),
                ),
                SizedBox(width: isDesktop ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'إجمالي الأرصدة' : 'Total Balance',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 6 : 4),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settings) {
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;
                          return Text(
                            '${accountState.totalBalance.toStringAsFixed(2)} ${settings.currencySymbol}',
                            style: TextStyle(
                              fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                              color:
                                  isDarkMode
                                      ? Colors.blue.shade300
                                      : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        '${accountState.activeAccounts.length} ${isRTL ? "حساب نشط" : "active accounts"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (accountState.lowBalanceAccounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.orange.shade900.withValues(alpha: 0.3)
                              : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isDarkMode
                                ? Colors.orange.shade700
                                : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color:
                              isDarkMode
                                  ? Colors.orange.shade400
                                  : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isRTL
                                ? '${accountState.lowBalanceAccounts.length} حساب منخفض الرصيد'
                                : '${accountState.lowBalanceAccounts.length} accounts with low balance',
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? Colors.orange.shade300
                                      : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
