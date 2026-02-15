import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/account_dialog.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

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
    context.read<AccountCubit>().loadAccounts();
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
              onPressed: () => context.read<AccountCubit>().loadAccounts(),
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
                          const SizedBox(width: AppSpacing.xs),
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
                          const SizedBox(width: AppSpacing.xs),
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
        body: BlocListener<ExpenseCubit, ExpenseState>(
          listenWhen:
              (previous, current) =>
                  previous.allExpenses.length != current.allExpenses.length,
          listener:
              (context, expenseState) =>
                  context.read<AccountCubit>().loadAccounts(),
          child: BlocBuilder<AccountCubit, AccountState>(
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
                    () async => context.read<AccountCubit>().loadAccounts(),
                child: Column(
                  children: [
                    AccountsSummaryCard(
                      accountState: accountState,
                      isRTL: isRTL,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? AppSpacing.xl : AppSpacing.md,
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
      builder: (context) => const AccountDialog(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الحساب بنجاح'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleAccountAction(String action, AccountEntity account) async {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    switch (action) {
      case 'edit':
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AccountDialog(account: account),
        );

        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الحساب بنجاح'),
              backgroundColor: AppColors.success,
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
                    onPressed: () => context.pop(false),
                    child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: () => context.pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(isRTL ? 'حذف' : 'Delete'),
                  ),
                ],
              ),
        );

        if (confirm == true && mounted) {
          context.read<AccountCubit>().deleteAccount(account.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isRTL ? 'تم حذف الحساب' : 'Account deleted'),
              backgroundColor: AppColors.warning,
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
