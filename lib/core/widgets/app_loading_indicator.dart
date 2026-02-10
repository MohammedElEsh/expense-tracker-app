import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  /// Full-page loading indicator
  const AppLoadingIndicator.page({super.key, this.message})
    : size = 48,
      color = null;

  /// Inline/small loading indicator
  const AppLoadingIndicator.inline({super.key, this.message})
    : size = 24,
      color = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: size > 30 ? 3 : 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for content loading states
class AppShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
  });

  @override
  State<AppShimmerLoading> createState() => _AppShimmerLoadingState();
}

class _AppShimmerLoadingState extends State<AppShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);
    final highlightColor =
        isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}
