// ✅ Refactored Budget Management Screen - Clean & Modular
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';

// Import refactored widgets
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_month_selector.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_category_card.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_add_dialog.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_screen.dart';
import 'package:expense_tracker/features/budgets/utils/budget_calculations.dart';
import 'package:expense_tracker/core/widgets/animated_page_route.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load budgets for the current month on init
    _loadBudgetsForSelectedMonth();
  }

  void _loadBudgetsForSelectedMonth() {
    context.read<BudgetCubit>().loadBudgetsForMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
  }

  Future<void> _refreshBudgets() async {
    context.read<BudgetCubit>().refreshBudgets(
      selectedMonth.year,
      selectedMonth.month,
    );
    // Wait for the state to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, budgetState) {
            return BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, expenseState) {
                final isRTL = settings.language == 'ar';

                return Directionality(
                  textDirection:
                      isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                  child: Scaffold(
                    appBar: _buildAppBar(isRTL),
                    body: RefreshIndicator(
                      onRefresh: _refreshBudgets,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // 1. Month Selector
                          SliverToBoxAdapter(
                            child: BudgetMonthSelector(
                              selectedMonth: selectedMonth,
                              isRTL: isRTL,
                              onPreviousMonth: _previousMonth,
                              onNextMonth: _nextMonth,
                            ),
                          ),

                          // 2. Summary Card
                          SliverToBoxAdapter(
                            child: _buildSummary(
                              budgetState,
                              expenseState,
                              settings,
                              isRTL,
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.md),
                          ),

                          // 3. Budget Categories List
                          _buildBudgetSliver(
                            budgetState,
                            expenseState,
                            settings,
                            isRTL,
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      heroTag: 'budget_add_fab',
                      onPressed:
                          () => _showAddBudgetDialog(context, settings, isRTL),
                      child: const Icon(Icons.add),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isRTL) {
    return AppBar(
      title: Text(
        isRTL ? 'إدارة الميزانية' : 'Budget Management',
        style: AppTypography.headlineSmall.copyWith(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectMonth(context),
        ),
      ],
    );
  }

  Widget _buildSummary(
    BudgetState budgetState,
    ExpenseState expenseState,
    SettingsState settings,
    bool isRTL,
  ) {
    final monthBudgets = _getMonthBudgets(budgetState, settings);
    final totalBudget = BudgetCalculations.calculateTotalBudget(monthBudgets);
    final totalSpent = BudgetCalculations.calculateTotalSpent(
      expenseState.expenses,
      monthBudgets,
      selectedMonth,
    );
    final remaining = BudgetCalculations.calculateRemaining(
      totalBudget,
      totalSpent,
    );

    return BudgetSummaryCard(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      remaining: remaining,
      settings: settings,
      isRTL: isRTL,
    );
  }

  Widget _buildBudgetSliver(
    BudgetState budgetState,
    ExpenseState expenseState,
    SettingsState settings,
    bool isRTL,
  ) {
    final monthBudgets = _getMonthBudgets(budgetState, settings);

    if (budgetState.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (monthBudgets.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(isRTL));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final budget = monthBudgets[index];
        final spent = BudgetCalculations.calculateCategorySpent(
          expenseState.expenses,
          budget.category,
          selectedMonth,
        );

        return BudgetCategoryCard(
          budget: budget,
          spent: spent,
          settings: settings,
          isRTL: isRTL,
          onTap: () => _navigateToBudgetDetails(budget, spent),
          onDelete: () => _deleteBudget(budget),
        );
      }, childCount: monthBudgets.length),
    );
  }

  Widget _buildEmptyState(bool isRTL) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: AppSpacing.iconXxl + 16,
            color:
                isDark
                    ? AppColors.iconInactiveDark
                    : AppColors.iconInactiveLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isRTL ? 'لا توجد ميزانيات' : 'No Budgets',
            style: AppTypography.headlineSmall.copyWith(
              color:
                  isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // ============= Helper Methods =============

  List<Budget> _getMonthBudgets(
    BudgetState budgetState,
    SettingsState settings,
  ) {
    // API already filters by appMode and userId
    // Just filter by selected month/year for display
    return budgetState.allBudgets.where((budget) {
      return budget.month == selectedMonth.month &&
          budget.year == selectedMonth.year &&
          budget.limit > 0; // Exclude deleted budgets (limit = 0)
    }).toList();
  }

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
    _loadBudgetsForSelectedMonth();
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
    _loadBudgetsForSelectedMonth();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedMonth = picked);
      _loadBudgetsForSelectedMonth();
    }
  }

  void _navigateToBudgetDetails(Budget budget, double spent) {
    Navigator.push(
      context,
      AnimatedPageRoute(
        child: BudgetDetailsScreen(budget: budget, spent: spent),
      ),
    );
  }

  void _deleteBudget(Budget budget) {
    context.read<BudgetCubit>().deleteBudget(
      budget.category,
      budget.year,
      budget.month,
    );
  }

  void _showAddBudgetDialog(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => BudgetAddDialog(
            selectedMonth: selectedMonth,
            isRTL: isRTL,
            appMode: settings.appMode,
            onSave: (category, limit) {
              final budget = Budget(
                id: '${selectedMonth.year}_${selectedMonth.month}_$category',
                category: category,
                limit: limit,
                spent: 0.0,
                month: selectedMonth.month,
                year: selectedMonth.year,
                createdAt: DateTime.now(),
              );
              context.read<BudgetCubit>().saveBudget(
                category: budget.category,
                limit: budget.limit,
                month: budget.month,
                year: budget.year,
              );
              Navigator.of(dialogContext).pop();
            },
          ),
    );
  }
}
