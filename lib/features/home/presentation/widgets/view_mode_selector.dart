// Home Feature - Presentation Layer - View Mode Selector Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

class ViewModeSelector extends StatelessWidget {
  final bool isRTL;
  final String currentViewMode;
  final Function(String) onViewModeChanged;

  const ViewModeSelector({
    super.key,
    required this.isRTL,
    required this.currentViewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(AppSpacing.xxxs),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isRTL ? 'اختر طريقة العرض' : 'Select View Mode',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildViewModeOption(context, 'all', isRTL ? 'الكل' : 'All'),
          _buildViewModeOption(context, 'day', isRTL ? 'اليوم' : 'Day'),
          _buildViewModeOption(context, 'week', isRTL ? 'الأسبوع' : 'Week'),
          _buildViewModeOption(context, 'month', isRTL ? 'الشهر' : 'Month'),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildViewModeOption(BuildContext context, String mode, String label) {
    final isSelected = currentViewMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // أغلق الـ BottomSheet أولاً
        onViewModeChanged(mode); // ثم غيّر الوضع
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : null,
          border: Border(
            bottom: BorderSide(color: borderColor.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: AppSpacing.iconMd,
              ),
            if (isSelected) const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
