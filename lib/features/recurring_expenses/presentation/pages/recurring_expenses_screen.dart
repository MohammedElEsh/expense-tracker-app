// ✅ Clean Architecture - UI depends only on Cubit and RecurringExpenseEntity
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_state.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/recurring_expense_dialog.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/recurring_expense_item.dart';
import 'package:expense_tracker/core/widgets/empty_state_widget.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
class RecurringExpensesScreen extends StatefulWidget {
  const RecurringExpensesScreen({super.key});

  @override
  State<RecurringExpensesScreen> createState() => _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecurringExpenseCubit>().loadRecurringExpenses();
  }

  Future<void> _addRecurringExpense() async {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final accountState = context.read<AccountCubit>().state;

    if (accountState.accounts.isEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRTL ? 'لا توجد حسابات بنكية!' : 'No Bank Accounts!',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
          content: Text(
            isRTL
                ? 'يجب إضافة حساب بنكي واحد على الأقل قبل إضافة المصروفات المتكررة.\n\nهل تريد إضافة حساب الآن؟'
                : 'You must add at least one bank account before adding recurring expenses.\n\nDo you want to add an account now?',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(isRTL ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => context.pop(true),
              icon: const Icon(Icons.add),
              label: Text(isRTL ? 'إضافة حساب' : 'Add Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        context.push(AppRoutes.accounts);
      }
      return;
    }

    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => const RecurringExpenseDialog(),
    );

    if (dialogResult == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'تم إضافة المصروف المتكرر بنجاح' : 'Recurring expense added successfully',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editRecurringExpense(RecurringExpenseEntity expense) async {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RecurringExpenseDialog(recurringExpense: expense),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'تم تحديث المصروف المتكرر بنجاح' : 'Recurring expense updated successfully',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteRecurringExpense(RecurringExpenseEntity expense) async {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          isRTL ? 'هل أنت متأكد من حذف "${expense.notes}"؟' : 'Are you sure you want to delete "${expense.notes}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(isRTL ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isRTL ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<RecurringExpenseCubit>().deleteRecurringExpense(expense.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isRTL ? 'تم حذف المصروف المتكرر' : 'Recurring expense deleted'),
        ),
      );
    }
  }

  void _toggleExpense(RecurringExpenseEntity expense) {
    context.read<RecurringExpenseCubit>().toggleRecurringExpense(expense.id, !expense.isActive);
  }

  Widget _buildSummaryCard(RecurringExpenseState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.repeat, color: Theme.of(context).primaryColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settings) {
                      final isRTL = settings.language == 'ar';
                      return Text(
                        isRTL ? 'إجمالي المصروفات الشهرية' : 'Monthly Recurring Total',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: settings.secondaryTextColor),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settings) {
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        '${state.monthlyTotal.toStringAsFixed(2)} ${settings.currencySymbol}',
                        style: TextStyle(
                          fontSize: 26,
                          color: isDarkMode ? Colors.blue.shade300 : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settings) {
                      final isRTL = settings.language == 'ar';
                      return Row(
                        children: [
                          _buildStatusChip(
                            isRTL ? '${state.totalActiveRecurringExpenses} نشط' : '${state.totalActiveRecurringExpenses} Active',
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          if (state.totalInactiveRecurringExpenses > 0)
                            _buildStatusChip(
                              isRTL ? '${state.totalInactiveRecurringExpenses} متوقف' : '${state.totalInactiveRecurringExpenses} Inactive',
                              Colors.grey,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isRTL ? 'المصروفات المتكررة' : 'Recurring Expenses'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addRecurringExpense,
              tooltip: isRTL ? 'إضافة' : 'Add',
            ),
          ],
        ),
        body: BlocConsumer<RecurringExpenseCubit, RecurringExpenseState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
              );
            }
            if (state.lastError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.lastError!), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.allRecurringExpenses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<RecurringExpenseCubit>();
                bloc.refreshRecurringExpenses();
                await bloc.stream.firstWhere((s) => !s.isLoading);
              },
              child: state.allRecurringExpenses.isEmpty
                  ? const RecurringExpenseEmptyState()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildSummaryCard(state),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.filteredRecurringExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = state.filteredRecurringExpenses[index];
                              return RecurringExpenseItem(
                                expense: expense,
                                onEdit: () => _editRecurringExpense(expense),
                                onDelete: () => _deleteRecurringExpense(expense),
                                onToggle: () => _toggleExpense(expense),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'recurring_expense_add_fab',
          onPressed: _addRecurringExpense,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class RecurringExpenseEmptyState extends StatelessWidget {
  const RecurringExpenseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final screen = context.findAncestorStateOfType<_RecurringExpensesScreenState>();

    return EmptyStateWidget(
      icon: Icons.repeat,
      title: isRTL ? 'لا توجد مصروفات متكررة' : 'No Recurring Expenses',
      subtitle: isRTL
          ? 'قم بإضافة مصروفاتك الثابتة مثل الإيجار والفواتير لتتم إضافتها تلقائياً'
          : 'Add your fixed expenses like rent and bills to be added automatically',
      actionText: isRTL ? 'إضافة مصروف متكرر' : 'Add Recurring Expense',
      onAction: () => screen?._addRecurringExpense(),
    );
  }
}
