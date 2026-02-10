// Accounts - Account List Item Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/account_details_screen.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  final AccountState accountState;
  final bool isRTL;
  final Function(String, Account) onAction;

  const AccountListItem({
    super.key,
    required this.account,
    required this.accountState,
    required this.isRTL,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            AnimatedPageRoute(child: AccountDetailsScreen(account: account)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: account.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(account.icon, color: account.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: account.isActive ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, settings) {
                            return Text(
                              account.type.displayName,
                              style: TextStyle(
                                color:
                                    settings.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildPopupMenu(context),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settings) {
                  final isDarkMode = settings.isDarkMode;
                  return Text(
                    '${account.balance.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          account.balance >= 0
                              ? (isDarkMode
                                  ? Colors.green.shade400
                                  : Colors.green.shade700)
                              : (isDarkMode
                                  ? Colors.red.shade400
                                  : Colors.red.shade700),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => onAction(value, account),
      itemBuilder:
          (context) => [
            // PopupMenuItem(
            //   value: 'details',
            //   child: Row(
            //     children: [
            //       const Icon(Icons.info_outline),
            //       const SizedBox(width: 8),
            //       Text(isRTL ? 'عرض التفاصيل' : 'View Details'),
            //     ],
            //   ),
            // ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(isRTL ? 'تعديل' : 'Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Builder(
                builder: (context) {
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  final deleteColor =
                      isDarkMode ? Colors.red.shade400 : Colors.red.shade700;
                  return Row(
                    children: [
                      Icon(Icons.delete, color: deleteColor),
                      const SizedBox(width: 8),
                      Text(
                        isRTL ? 'حذف' : 'Delete',
                        style: TextStyle(color: deleteColor),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
    );
  }
}
