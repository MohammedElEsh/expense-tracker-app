// Home Feature - Presentation Layer - Home Summary Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';

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
          margin: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
          padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 32 : 20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [const Color(0xFF1976D2), const Color(0xFF1565C0)]
                      : [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.borderRadius),
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
                  Text(
                    viewModeTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 24 : (isTablet ? 20 : 16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewModeTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : (isTablet ? 12 : 8),
                        vertical: isDesktop ? 10 : (isTablet ? 8 : 4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          context.borderRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: isDesktop ? 26 : (isTablet ? 24 : 20),
                          ),
                          Text(
                            viewModeLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 28 : (isTablet ? 24 : 20)),
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 10 : (isTablet ? 8 : 4)),
                        Text(
                          '$currencySymbol ${NumberFormat('#,##0.00').format(totalAmount)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(
                      isDesktop ? 20 : (isTablet ? 16 : 12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(context.borderRadius),
                    ),
                    child: Column(
                      children: [
                        Text(
                          transactionCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 6 : (isTablet ? 4 : 2)),
                        Text(
                          isRTL ? 'مصروف' : 'Expense',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
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
