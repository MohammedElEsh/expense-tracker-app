// Expense Details - Header Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/date_time_utils.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';

class ExpenseHeaderCard extends StatelessWidget {
  final Expense expense;
  final bool isRTL;
  final String currency;

  const ExpenseHeaderCard({
    super.key,
    required this.expense,
    required this.isRTL,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final categoryEmoji = _getCategoryEmoji(expense.category);
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xxl : AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(context.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: isDesktop ? 12 : 10,
            offset: Offset(0, isDesktop ? 5 : 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الأيقونة
          Container(
            padding: EdgeInsets.all(isDesktop ? AppSpacing.lg : AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              categoryEmoji,
              style: TextStyle(fontSize: isDesktop ? 60 : (isTablet ? 56 : 48)),
            ),
          ),
          SizedBox(height: isDesktop ? AppSpacing.lg : AppSpacing.md),

          // المبلغ
          Text(
            '${NumberFormat('#,##0.00').format(expense.amount)} $currency',
            style: AppTypography.displayLarge.copyWith(
              fontSize: isDesktop ? 40 : (isTablet ? 36 : 32),
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? AppSpacing.sm : AppSpacing.xs),

          // الفئة
          Text(
            _getCategoryName(expense.getDisplayCategoryName(), isRTL),
            style: AppTypography.headlineLarge.copyWith(
              fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isDesktop ? AppSpacing.xxs + 2 : AppSpacing.xxs),

          // التاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white70,
                size: isDesktop ? 18.0 : AppSpacing.iconXs,
              ),
              SizedBox(width: isDesktop ? AppSpacing.xs + 2 : AppSpacing.xs),
              Text(
                DateTimeUtils.formatExpenseDateHeader(
                  expenseDate: expense.date,
                  isRTL: isRTL,
                ),
                style: (isDesktop
                        ? AppTypography.bodyLarge
                        : AppTypography.bodyMedium)
                    .copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    // Emoji mappings for categories (categories are already in Arabic from backend)
    final emojiMap = {
      // Personal categories
      'طعام ومطاعم': '🍔',
      'مواصلات وتنقل': '🚗',
      'ترفيه وتسلية': '🎬',
      'تسوق': '🛍️',
      'فواتير واشتراكات': '📄',
      'صحة ورعاية طبية': '🏥',
      'أخرى': '📦',
      // Business categories
      'رواتب الموظفين': '💼',
      'ايجار المكتب': '🏢',
      'إيجار': '🏢',
      'فواتير كهرباء': '💡',
      'فواتير مياه': '💧',
      'فواتير': '💧',
      'صيانة وإصلاحات': '🔧',
      'صيانة عدادات': '🔧',
      'تسويق وإعلانات': '📢',
      'تسويق واعلانات': '📢',
      'سفر': '✈️',
      'سفروانتقالات ': '✈️',
      'مشتريات مكتبية': '📋',
      'مستلزمات': '📋',
      'تامين': '🛡️',
      'ضرائب': '💰',
      'ضرائب ورسوم': '💰',
      'أجور': '💼',
      'فوائد بنكية': '💰',
      'تدريب وتطوير': '📚',
      'طعام ومشروبات': '🍔',
      'اخرى': '📦',
    };

    return emojiMap[category] ?? '💰';
  }

  String _getCategoryName(String category, bool isRTL) {
    // Categories are already in Arabic from backend
    return Categories.getDisplayName(category, isRTL);
  }
}
