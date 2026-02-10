import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

enum AppCardVariant { elevated, flat, outlined }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
  }) : variant = AppCardVariant.flat;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
  }) : variant = AppCardVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppSpacing.radiusMd;

    final cardColor =
        color ??
        (variant == AppCardVariant.flat
            ? (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5))
            : theme.cardColor);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        border:
            variant == AppCardVariant.outlined
                ? Border.all(
                  color:
                      isDark
                          ? const Color(0xFF5C5C5C)
                          : const Color(0xFFE0E0E0),
                )
                : null,
        boxShadow:
            variant == AppCardVariant.elevated
                ? [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withValues(
                      alpha: isDark ? 0.3 : 0.08,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: card,
        ),
      );
    }

    return card;
  }
}
