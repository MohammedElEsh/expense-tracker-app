import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: errorColor.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 40, color: errorColor),
            ),
            const SizedBox(height: AppSpacing.md),
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.headlineSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(retryLabel ?? 'Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
