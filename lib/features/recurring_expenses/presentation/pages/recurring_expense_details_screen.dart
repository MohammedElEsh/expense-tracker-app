// ✅ Clean Architecture - Recurring Expense Details Screen (Refactored)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';

// Import Widgets
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/details/recurring_expense_header_card.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/details/recurring_expense_status_frequency_card.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/details/recurring_expense_schedule_card.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/details/recurring_expense_details_card.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/widgets/recurring_expense_dialog.dart';

class RecurringExpenseDetailsScreen extends StatefulWidget {
  final RecurringExpense recurringExpense;

  const RecurringExpenseDetailsScreen({
    super.key,
    required this.recurringExpense,
  });

  @override
  State<RecurringExpenseDetailsScreen> createState() =>
      _RecurringExpenseDetailsScreenState();
}

class _RecurringExpenseDetailsScreenState
    extends State<RecurringExpenseDetailsScreen>
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
    return BlocBuilder<SettingsCubit, SettingsState>(
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
                isRTL ? 'تفاصيل المصروف المتكرر' : 'Recurring Expense Details',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToDetails(context),
                  tooltip:
                      isRTL
                          ? 'تعديل المصروف المتكرر'
                          : 'Edit Recurring Expense',
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recurring Expense Header Card
                      RecurringExpenseHeaderCard(
                        recurringExpense: widget.recurringExpense,
                        settings: settings,
                        isRTL: isRTL,
                        isDesktop: isDesktop,
                      ),
                      const SizedBox(height: 24),

                      // Status and Frequency Card
                      RecurringExpenseStatusFrequencyCard(
                        recurringExpense: widget.recurringExpense,
                        settings: settings,
                        isRTL: isRTL,
                        isDesktop: isDesktop,
                      ),
                      const SizedBox(height: 24),

                      // Schedule Information Card
                      RecurringExpenseScheduleCard(
                        recurringExpense: widget.recurringExpense,
                        settings: settings,
                        isRTL: isRTL,
                        isDesktop: isDesktop,
                      ),
                      const SizedBox(height: 24),

                      // Expense Details Card
                      RecurringExpenseDetailsCard(
                        recurringExpense: widget.recurringExpense,
                        settings: settings,
                        isRTL: isRTL,
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Navigate to edit the recurring expense
  Future<void> _navigateToDetails(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) =>
              RecurringExpenseDialog(recurringExpense: widget.recurringExpense),
    );

    if (result == true && mounted) {
      // Pop back to list screen to see updated data
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }
}
