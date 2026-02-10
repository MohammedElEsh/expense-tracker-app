import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/constants/categories.dart';

class BudgetCategoryCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final SettingsState settings;
  final bool isRTL;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCategoryCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.settings,
    required this.isRTL,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;
    final remaining = budget.limit - spent;
    final isOverBudget = spent > budget.limit;

    final isDark = settings.isDarkMode;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final subtextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: _getCategoryColor(),
                          size: AppSpacing.iconMd,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Categories.getDisplayName(budget.category, isRTL),
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${budget.limit.toStringAsFixed(2)} ${settings.currencySymbol}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // if (onDelete != null)
                  // IconButton(
                  //   icon: const Icon(Icons.delete),
                  //   color: AppColors.error,
                  //   onPressed: onDelete,
                  // ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor:
                    isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? errorColor : successColor,
                ),
                minHeight: AppSpacing.xs,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isRTL ? 'المتبقي' : 'Remaining'}: ${remaining.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isOverBudget ? errorColor : subtextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: isOverBudget ? errorColor : subtextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (budget.category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return AppColors.warning;
      case 'transport':
      case 'مواصلات':
        return AppColors.primary;
      case 'shopping':
      case 'تسوق':
        return const Color(0xFF9C27B0); // Purple
      case 'entertainment':
      case 'ترفيه':
        return const Color(0xFFE91E63); // Pink
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon() {
    switch (budget.category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Icons.restaurant;
      case 'transport':
      case 'مواصلات':
        return Icons.directions_car;
      case 'shopping':
      case 'تسوق':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'ترفيه':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}
