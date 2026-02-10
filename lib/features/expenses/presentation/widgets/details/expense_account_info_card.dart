// Expense Details - Account Info Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class ExpenseAccountInfoCard extends StatelessWidget {
  final Account? account;
  final bool isRTL;
  final String currency;

  const ExpenseAccountInfoCard({
    super.key,
    required this.account,
    required this.isRTL,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (account == null) return const SizedBox.shrink();

    return _buildCard(
      context,
      title: isRTL ? 'الحساب' : 'Account',
      icon: Icons.account_balance_wallet,
      child: Column(
        children: [
          _buildDetailRow(
            context,
            icon: Icons.account_balance,
            label: isRTL ? 'اسم الحساب' : 'Account Name',
            value: account!.name,
            isRTL: isRTL,
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.payments,
            label: isRTL ? 'نوع الحساب' : 'Account Type',
            value: _getAccountTypeName(account!.type, isRTL),
            isRTL: isRTL,
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: isRTL ? 'الرصيد الحالي' : 'Current Balance',
            value:
                '${NumberFormat('#,##0.00').format(account!.balance)} $currency',
            isRTL: isRTL,
            valueColor: account!.balance >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isRTL,
    Color? valueColor,
  }) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          settings.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          valueColor ??
                          (settings.isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getAccountTypeName(AccountType type, bool isRTL) {
    switch (type) {
      case AccountType.cash:
        return isRTL ? 'نقدي' : 'Cash';
      case AccountType.bank:
        return isRTL ? 'بنكي' : 'Bank';
      case AccountType.credit:
        return isRTL ? 'بطاقة ائتمان' : 'Credit Card';
      case AccountType.debit:
        return isRTL ? 'بطاقة خصم مباشر' : 'Debit Card';
      case AccountType.digital:
        return isRTL ? 'محفظة رقمية' : 'Digital Wallet';
      case AccountType.gift:
        return isRTL ? 'بطاقة هدية' : 'Gift Card';
      case AccountType.investment:
        return isRTL ? 'استثمار' : 'Investment';
      case AccountType.savings:
        return isRTL ? 'توفير' : 'Savings';
    }
  }
}
