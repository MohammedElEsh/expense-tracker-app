// ✅ Clean Architecture - Recurring Expense Item (domain entity only)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/utils/recurring_expense_display_helper.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/utils/theme_helper.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class RecurringExpenseItem extends StatelessWidget {
  final RecurringExpenseEntity expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const RecurringExpenseItem({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  String _getNextDueText(bool isRTL) {
    final nextDue = expense.nextDueDate;
    final now = DateTime.now();
    final difference = nextDue.difference(now).inDays;

    if (difference == 0) {
      return isRTL ? 'اليوم' : 'Today';
    } else if (difference == 1) {
      return isRTL ? 'غداً' : 'Tomorrow';
    } else if (difference < 7) {
      return isRTL ? 'خلال $difference أيام' : 'In $difference days';
    } else {
      return DateFormat('d MMM yyyy').format(nextDue);
    }
  }

  Color _getStatusColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!expense.isActive) {
      return isDarkMode
          ? AppColors.textTertiaryDark
          : AppColors.textSecondaryLight;
    }

    final nextDue = expense.nextDueDate;
    final now = DateTime.now();
    final difference = nextDue.difference(now).inDays;

    if (difference <= 0) {
      return isDarkMode ? AppColors.darkError : AppColors.error;
    } else if (difference <= 3) {
      return isDarkMode ? AppColors.darkWarning : AppColors.warning;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  void _navigateToDetails(BuildContext context) {
    context.push(AppRoutes.recurringExpenseDetails, extra: expense);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Opacity(
            opacity: expense.isActive ? 1.0 : 0.6,
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => _navigateToDetails(context),

              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(
                      context,
                    ).withValues(alpha: 0.1),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: _getStatusColor(context),
                    ),
                  ),
                  // Status indicator dot
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: AppSpacing.sm,
                      height: AppSpacing.sm,
                      decoration: BoxDecoration(
                        color:
                            expense.isActive
                                ? AppColors.success
                                : AppColors.badgeInactive,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      expense.notes.isNotEmpty
                          ? expense.notes
                          : (isRTL
                              ? Categories.getArabicName(expense.category)
                              : expense.category),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            expense.isActive
                                ? context.primaryTextColor
                                : context.tertiaryTextColor,
                        decoration:
                            expense.isActive
                                ? null
                                : TextDecoration.lineThrough,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (!expense.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeInactive.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Text(
                        isRTL ? 'متوقف' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.tertiaryTextColor,
                        ),
                      ),
                    ),
                ],
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ✅ FIX: make the row resilient to small widths / RTL
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: context.iconColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isRTL
                              ? Categories.getArabicName(expense.category)
                              : expense.category,
                          style: TextStyle(color: context.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.repeat, size: 16, color: context.iconColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          expense.recurrenceType.displayName(isRTL),
                          style: TextStyle(color: context.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),

                  // Show account name if available
                  if (expense.accountName != null &&
                      expense.accountName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: context.iconColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            expense.accountName!,
                            style: TextStyle(
                              color: context.secondaryTextColor,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  if (expense.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: _getStatusColor(context),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isRTL
                                  ? 'التالي: ${_getNextDueText(isRTL)}'
                                  : 'Next: ${_getNextDueText(isRTL)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // ✅ FIX: trailing overflow (remove fixed 95 width, use min + Flexible)
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Builder(
                        builder: (context) {
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;

                          return Text(
                            '${expense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  expense.isActive
                                      ? (isDarkMode
                                          ? AppColors.darkPrimary
                                          : Theme.of(context).primaryColor)
                                      : context.tertiaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.end,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        switch (value) {
                          case 'details':
                            _navigateToDetails(context);
                            break;
                          case 'edit':
                            onEdit();
                            break;
                          case 'toggle':
                            onToggle();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(isRTL ? 'عرض التفاصيل' : 'View Details'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(isRTL ? 'تعديل' : 'Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    expense.isActive
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline,
                                    color:
                                        expense.isActive
                                            ? AppColors.warning
                                            : AppColors.success,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    expense.isActive
                                        ? (isRTL ? 'إيقاف' : 'Deactivate')
                                        : (isRTL ? 'تفعيل' : 'Activate'),
                                    style: TextStyle(
                                      color:
                                          expense.isActive
                                              ? AppColors.warning
                                              : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Builder(
                                builder: (context) {
                                  final isDarkMode =
                                      Theme.of(context).brightness ==
                                      Brightness.dark;
                                  final deleteColor =
                                      isDarkMode
                                          ? AppColors.darkError
                                          : AppColors.error;

                                  return Row(
                                    children: [
                                      Icon(Icons.delete, color: deleteColor),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        isRTL ? 'حذف' : 'Delete',
                                        style: TextStyle(color: deleteColor),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
