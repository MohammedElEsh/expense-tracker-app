import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/details/vendor_header_card.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/details/vendor_statistics_section.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/details/vendor_info_card.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/details/vendor_expenses_section.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/vendor_dialog.dart';

class VendorDetailsScreen extends StatefulWidget {
  final VendorEntity vendor;

  const VendorDetailsScreen({super.key, required this.vendor});

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late VendorEntity _currentVendor;

  @override
  void initState() {
    super.initState();
    _currentVendor = widget.vendor;
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
    return BlocListener<VendorCubit, VendorState>(
      listener: (context, state) {
        if (state is VendorLoaded && mounted) {
          final list = state.vendors.where((v) => v.id == _currentVendor.id).toList();
          if (list.isNotEmpty) {
            setState(() => _currentVendor = list.first);
          }
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
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
                isRTL ? 'تفاصيل المورد' : 'Vendor Details',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                BlocBuilder<VendorCubit, VendorState>(
                  builder: (context, vendorState) {
                    final refreshing = vendorState is VendorLoading;
                    return IconButton(
                      icon: refreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_outlined),
                      onPressed: refreshing ? null : () => _showEditVendorDialog(),
                      tooltip: isRTL ? 'تعديل المورد' : 'Edit Vendor',
                    );
                  },
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, expenseState) {
                    final vendorExpenses = _getVendorExpenses(expenseState);
                    final totalExpenses = _getTotalExpenses(vendorExpenses);
                    final monthlyExpenses = _getMonthlyExpenses(vendorExpenses);
                    final averageExpense = _getAverageExpense(vendorExpenses);

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Vendor Header Card
                          VendorHeaderCard(
                            vendor: _currentVendor,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: 24),

                          // 2. Statistics Section
                          VendorStatisticsSection(
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                            totalExpenses: totalExpenses,
                            monthlyExpenses: monthlyExpenses,
                            expenseCount: vendorExpenses.length,
                            averageExpense: averageExpense,
                          ),
                          const SizedBox(height: 24),

                          // 3. Vendor Info Card
                          VendorInfoCard(
                            vendor: _currentVendor,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: 24),

                          // 4. Expenses Section
                          VendorExpensesSection(
                            expenses: vendorExpenses,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                            onViewAll:
                                () => _showAllExpenses(
                                  vendorExpenses,
                                  settings,
                                  isRTL,
                                ),
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
      ),
    );
  }

  Future<void> _showEditVendorDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => VendorDialog(vendor: _currentVendor),
    );

    if (result == true && mounted) {
      context.read<VendorCubit>().loadVendors();
    }
  }

  List<Expense> _getVendorExpenses(ExpenseState expenseState) {
    if (expenseState.expenses.isNotEmpty) {
      return expenseState.expenses
          .where((expense) => expense.vendorName == _currentVendor.name)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    return [];
  }

  double _getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

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

  double _getAverageExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    final total = _getTotalExpenses(expenses);
    return total / expenses.length;
  }

  void _showAllExpenses(
    List<Expense> expenses,
    SettingsState settings,
    bool isRTL,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: settings.surfaceColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: settings.borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isRTL
                                  ? 'جميع مشتريات المورد'
                                  : 'All Vendor Purchases',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: settings.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: VendorExpensesSection(
                          expenses: expenses,
                          settings: settings,
                          isRTL: isRTL,
                          isDesktop: false,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
