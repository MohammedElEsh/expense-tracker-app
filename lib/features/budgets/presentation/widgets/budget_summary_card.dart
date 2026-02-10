import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final SettingsState settings;
  final bool isRTL;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;
    final isOverBudget = totalSpent > totalBudget;

    final overBudgetColor =
        settings.isDarkMode ? AppColors.darkError : AppColors.error;
    final normalColor =
        settings.isDarkMode ? AppColors.darkPrimary : AppColors.primary;
    final overBudgetGradientEnd =
        settings.isDarkMode ? const Color(0xFFB71C1C) : const Color(0xFFD32F2F);
    final normalGradientEnd =
        settings.isDarkMode ? AppColors.darkPrimaryDark : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isOverBudget
                  ? [overBudgetColor, overBudgetGradientEnd]
                  : [normalColor, normalGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? overBudgetColor : normalColor).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'إجمالي الميزانية' : 'Total Budget',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${totalBudget.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: AppTypography.amountSmall.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isRTL ? 'المتبقي' : 'Remaining',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${remaining.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: AppTypography.amountSmall.copyWith(
                      color:
                          isOverBudget
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.white.withOpacity(0.7) : Colors.white,
            ),
            minHeight: AppSpacing.xs,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% ${isRTL ? 'مستخدم' : 'Used'}',
                style: AppTypography.bodySmall.copyWith(color: Colors.white70),
              ),
              Text(
                '${totalSpent.toStringAsFixed(2)} ${settings.currencySymbol}',
                style: AppTypography.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
