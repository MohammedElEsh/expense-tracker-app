import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, danger, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  // Named constructors for convenience
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.primary,
       size = AppButtonSize.medium;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.secondary,
       size = AppButtonSize.medium;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.outline,
       size = AppButtonSize.medium;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.danger,
       size = AppButtonSize.medium;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.text,
       size = AppButtonSize.medium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget child =
        isLoading
            ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getForegroundColor(theme),
                ),
              ),
            )
            : Row(
              mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: size == AppButtonSize.small ? 16 : 20),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(label, style: textStyle),
              ],
            );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            elevation: 2,
          ),
          child: child,
        );
        break;
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            elevation: 0,
          ),
          child: child,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            side: BorderSide(color: theme.colorScheme.primary),
          ),
          child: child,
        );
        break;
      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            elevation: 2,
          ),
          child: child,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          child: child,
        );
        break;
    }

    return button;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case AppButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case AppButtonSize.large:
        return AppSpacing.buttonHeightLg;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.labelMedium;
      case AppButtonSize.medium:
        return AppTypography.button;
      case AppButtonSize.large:
        return AppTypography.button.copyWith(fontSize: 16);
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return theme.colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return theme.colorScheme.onSecondaryContainer;
      case AppButtonVariant.outline:
        return theme.colorScheme.primary;
      case AppButtonVariant.danger:
        return theme.colorScheme.onError;
      case AppButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}
