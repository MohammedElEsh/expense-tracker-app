import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/account_dialog_refactored.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';

// Import Widgets
import 'package:expense_tracker/features/accounts/presentation/widgets/list/accounts_summary_card.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/list/account_list_item.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/list/accounts_empty_state.dart';

// ✅ Clean Architecture - Accounts Screen (Refactored)

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _showInactiveAccounts = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(const LoadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isRTL ? 'إدارة الحسابات' : 'Manage Accounts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed:
                  () => context.read<AccountBloc>().add(const LoadAccounts()),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle_inactive') {
                  setState(
                    () => _showInactiveAccounts = !_showInactiveAccounts,
                  );
                } else if (value == 'add_account') {
                  _showAddAccountDialog();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'add_account',
                      child: Row(
                        children: [
                          const Icon(Icons.add),
                          const SizedBox(width: 8),
                          Text(isRTL ? 'إضافة حساب' : 'Add Account'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_inactive',
                      child: Row(
                        children: [
                          Icon(
                            _showInactiveAccounts
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showInactiveAccounts
                                ? (isRTL ? 'إخفاء المعطلة' : 'Hide Inactive')
                                : (isRTL ? 'إظهار المعطلة' : 'Show Inactive'),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        body: BlocListener<ExpenseBloc, ExpenseState>(
          listenWhen:
              (previous, current) =>
                  previous.allExpenses.length != current.allExpenses.length,
          listener:
              (context, expenseState) =>
                  context.read<AccountBloc>().add(const LoadAccounts()),
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              if (accountState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final accounts =
                  _showInactiveAccounts
                      ? accountState.accounts
                      : accountState.activeAccounts;

              if (accounts.isEmpty) {
                return const AccountsEmptyState();
              }

              final isDesktop = context.isDesktop;

              return RefreshIndicator(
                onRefresh:
                    () async =>
                        context.read<AccountBloc>().add(const LoadAccounts()),
                child: Column(
                  children: [
                    AccountsSummaryCard(
                      accountState: accountState,
                      isRTL: isRTL,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                        ),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          return AccountListItem(
                            account: accounts[index],
                            accountState: accountState,
                            isRTL: isRTL,
                            onAction: _handleAccountAction,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddAccountDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddAccountDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AccountDialogRefactored(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الحساب بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleAccountAction(String action, Account account) async {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    switch (action) {
      case 'edit':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AccountDialogRefactored(account: account),
        );

        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الحساب بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'delete':
        // Show confirmation dialog
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(isRTL ? 'حذف الحساب' : 'Delete Account'),
                content: Text(
                  isRTL
                      ? 'هل أنت متأكد من حذف حساب "${account.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.'
                      : 'Are you sure you want to delete "${account.name}"?\nThis action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(isRTL ? 'حذف' : 'Delete'),
                  ),
                ],
              ),
        );

        if (confirm == true && mounted) {
          context.read<AccountBloc>().add(DeleteAccount(account.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isRTL ? 'تم حذف الحساب' : 'Account deleted'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 'details':
        // Already handled by onTap
        break;
    }
  }
}
