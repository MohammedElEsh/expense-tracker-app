// Budget Header Card - عرض رأس صفحة تفاصيل الميزانية
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/features/budgets/utils/budget_helpers.dart';

class BudgetHeaderCard extends StatelessWidget {
  final Budget budget;
  final bool isRTL;
  final bool isDesktop;

  const BudgetHeaderCard({
    super.key,
    required this.budget,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = BudgetHelpers.getCategoryColor(budget.category);
    final categoryIcon = BudgetHelpers.getCategoryIcon(budget.category);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(categoryIcon, size: isDesktop ? 64 : 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            Categories.getDisplayName(budget.category, isRTL),
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMMM yyyy').format(DateTime(budget.year, budget.month)),
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
