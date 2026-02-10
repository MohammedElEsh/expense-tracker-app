import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';

// Import Widgets
import 'package:expense_tracker/features/accounts/presentation/widgets/details/account_header_card.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/details/account_statistics_cards.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/details/account_transactions_section.dart';

// ✅ Clean Architecture - Account Details Screen (Refactored)

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';
        final isDesktop = context.isDesktop;

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: settings.surfaceColor,
            appBar: AppBar(
              backgroundColor: settings.primaryColor,
              foregroundColor:
                  settings.isDarkMode ? Colors.black : Colors.white,
              elevation: 0,
              title: Text(
                isRTL ? 'تفاصيل الحساب' : 'Account Details',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, expenseState) {
                    final accountExpenses = _getAccountExpenses(expenseState);
                    final totalExpenses = _getTotalExpenses(accountExpenses);
                    final monthlyExpenses = _getMonthlyExpenses(
                      accountExpenses,
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account Header Card
                          AccountHeaderCard(
                            account: widget.account,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: 24),

                          // Statistics Cards
                          AccountStatisticsCards(
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                            totalExpenses: totalExpenses,
                            monthlyExpenses: monthlyExpenses,
                            transactionCount: accountExpenses.length,
                          ),
                          const SizedBox(height: 24),

                          // Transactions List
                          AccountTransactionsSection(
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                            expenses: accountExpenses,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// الحصول على مصروفات الحساب
  List<Expense> _getAccountExpenses(ExpenseState expenseState) {
    return expenseState.expenses
        .where((expense) => expense.accountId == widget.account.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// حساب إجمالي المصروفات
  double _getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// حساب مصروفات الشهر الحالي
  double _getMonthlyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final currentMonthExpenses =
        expenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();

    return currentMonthExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }
}
