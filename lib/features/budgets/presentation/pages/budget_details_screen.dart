// Budget Details Screen - عرض تفاصيل الميزانية (Refactored)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';

// Import refactored widgets
import 'package:expense_tracker/features/budgets/presentation/widgets/details/budget_header_card.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/details/budget_progress_card.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/details/budget_financial_details_card.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/details/budget_expenses_list_card.dart';
import 'package:expense_tracker/features/budgets/utils/budget_helpers.dart';

class BudgetDetailsScreen extends StatelessWidget {
  final Budget budget;
  final double spent;

  const BudgetDetailsScreen({
    super.key,
    required this.budget,
    required this.spent,
  });

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
            appBar: _buildAppBar(settings, isRTL),
            body: _buildBody(settings, isRTL, isDesktop),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SettingsState settings, bool isRTL) {
    final categoryColor = BudgetHelpers.getCategoryColor(budget.category);

    return AppBar(
      backgroundColor: categoryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        BudgetHelpers.getCategoryIcon(budget.category).toString().isNotEmpty
            ? ''
            : 'Budget Details',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody(SettingsState settings, bool isRTL, bool isDesktop) {
    return Builder(
      builder:
          (context) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getMaxContentWidth(context),
              ),
              child: ListView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                children: [
                  // Header Card
                  BudgetHeaderCard(
                    budget: budget,
                    isRTL: isRTL,
                    isDesktop: isDesktop,
                  ),

                  const SizedBox(height: 16),

                  // Progress Card
                  BudgetProgressCard(
                    budget: budget,
                    spent: spent,
                    settings: settings,
                    isRTL: isRTL,
                    isDesktop: isDesktop,
                  ),

                  const SizedBox(height: 16),

                  // Financial Details Card
                  BudgetFinancialDetailsCard(
                    budget: budget,
                    spent: spent,
                    settings: settings,
                    isRTL: isRTL,
                    isDesktop: isDesktop,
                  ),

                  const SizedBox(height: 16),

                  // Expenses List Card
                  BudgetExpensesListCard(
                    budget: budget,
                    settings: settings,
                    isRTL: isRTL,
                    isDesktop: isDesktop,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
