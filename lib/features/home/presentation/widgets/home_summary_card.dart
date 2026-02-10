// Home Feature - Presentation Layer - Home Summary Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

class HomeSummaryCard extends StatelessWidget {
  final bool isRTL;
  final bool isDesktop;
  final bool isTablet;
  final bool isDarkMode;
  final String viewModeTitle;
  final String viewModeLabel;
  final double totalAmount;
  final int transactionCount;
  final String currencySymbol;
  final Color primaryColor;
  final VoidCallback onViewModeTap;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const HomeSummaryCard({
    super.key,
    required this.isRTL,
    required this.isDesktop,
    required this.isTablet,
    required this.isDarkMode,
    required this.viewModeTitle,
    required this.viewModeLabel,
    required this.totalAmount,
    required this.transactionCount,
    required this.currencySymbol,
    required this.primaryColor,
    required this.onViewModeTap,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(
            isDesktop
                ? AppSpacing.xxl
                : (isTablet ? AppSpacing.xl : AppSpacing.md),
          ),
          padding: EdgeInsets.all(
            isDesktop
                ? AppSpacing.xxxl
                : (isTablet ? AppSpacing.xxl : AppSpacing.lg),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [AppColors.primaryDark, const Color(0xFF1565C0)]
                      : [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              isDesktop
                  ? AppSpacing.radiusLg
                  : (isTablet ? AppSpacing.radiusMd : AppSpacing.radiusMd),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: isDesktop ? 12 : 8,
                offset: Offset(0, isDesktop ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      viewModeTitle,
                      style: (isDesktop
                              ? AppTypography.headlineLarge
                              : (isTablet
                                  ? AppTypography.headlineMedium
                                  : AppTypography.titleMedium))
                          .copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewModeTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isDesktop
                                ? AppSpacing.md
                                : (isTablet ? AppSpacing.sm : AppSpacing.xs),
                        vertical:
                            isDesktop
                                ? AppSpacing.sm
                                : (isTablet ? AppSpacing.xs : AppSpacing.xxs),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size:
                                isDesktop
                                    ? AppSpacing.iconLg
                                    : (isTablet
                                        ? AppSpacing.iconMd
                                        : AppSpacing.iconSm),
                          ),
                          Text(
                            viewModeLabel,
                            style: (isDesktop
                                    ? AppTypography.titleLarge
                                    : (isTablet
                                        ? AppTypography.titleMedium
                                        : AppTypography.bodyMedium))
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height:
                    isDesktop
                        ? AppSpacing.xxl
                        : (isTablet ? AppSpacing.xl : AppSpacing.lg),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRTL ? 'الإجمالي' : 'Total',
                          style: (isDesktop
                                  ? AppTypography.titleLarge
                                  : (isTablet
                                      ? AppTypography.titleMedium
                                      : AppTypography.bodyMedium))
                              .copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        SizedBox(
                          height:
                              isDesktop
                                  ? AppSpacing.sm
                                  : (isTablet ? AppSpacing.xs : AppSpacing.xxs),
                        ),
                        Text(
                          '$currencySymbol ${NumberFormat('#,##0.00').format(totalAmount)}',
                          style: (isDesktop
                                  ? AppTypography.displayLarge
                                  : (isTablet
                                      ? AppTypography.displayMedium
                                      : AppTypography.amountLarge))
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(
                      isDesktop
                          ? AppSpacing.lg
                          : (isTablet ? AppSpacing.md : AppSpacing.sm),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          transactionCount.toString(),
                          style: (isDesktop
                                  ? AppTypography.displayLarge
                                  : (isTablet
                                      ? AppTypography.displayMedium
                                      : AppTypography.displaySmall))
                              .copyWith(color: Colors.white),
                        ),
                        SizedBox(
                          height:
                              isDesktop
                                  ? AppSpacing.xs
                                  : (isTablet
                                      ? AppSpacing.xxs
                                      : AppSpacing.xxxs),
                        ),
                        Text(
                          isRTL ? 'مصروف' : 'Expense',
                          style: (isDesktop
                                  ? AppTypography.titleMedium
                                  : (isTablet
                                      ? AppTypography.bodyMedium
                                      : AppTypography.bodySmall))
                              .copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
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
}
