import 'dart:io';

import 'package:expense_tracker/core/utils/date_time_utils.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_details_screen.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/core/services/permission_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final String currencySymbol;
  final bool isRTL;
  final VoidCallback onDelete;

  const ExpenseItem({
    super.key,
    required this.expense,
    required this.currencySymbol,
    required this.isRTL,
    required this.onDelete,
  });

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Healthcare':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  String _displayCategory() {
    final name = expense.getDisplayCategoryName();
    // Categories are already in Arabic from backend, so just use Categories.getDisplayName
    return Categories.getDisplayName(name, isRTL);
  }

  // ✅ Compact date-time: Uses expense.date for date, createdAt for time (matches Details view)
  String _compactDateTime() {
    // Use shared utility for consistent formatting
    final formatted = DateTimeUtils.formatExpenseDateTime(
      expenseDate: expense.date,
      createdAt: expense.createdAt,
      isRTL: isRTL,
    );

    // Debug logging to compare with Details view
    if (kDebugMode && expense.createdAt != null) {
      DateTimeUtils.debugDateTimeParsing(
        rawApiValue: expense.createdAt!.toIso8601String(),
        parsedDateTime: expense.createdAt!,
        renderedString: formatted,
        context: 'ExpenseItem',
      );
    }

    return formatted;
  }

  Color _amountColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkError : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          isTablet ? AppSpacing.radiusLg : AppSpacing.radiusMd,
        ),
        onTap: () => _navigateToDetails(context),
        child: Container(
          margin: EdgeInsets.only(
            bottom: isTablet ? AppSpacing.sm : AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(
              isTablet ? AppSpacing.radiusLg : AppSpacing.radiusMd,
            ),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 6),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? AppSpacing.md : AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Icon
                _CategoryAvatar(
                  icon: getCategoryIcon(expense.category),
                  size: isTablet ? 48 : 40,
                ),

                SizedBox(width: isTablet ? AppSpacing.sm + 2 : AppSpacing.sm),

                // Middle Content
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      // Title (notes or category)
                      Text(
                        expense.notes.isNotEmpty
                            ? expense.notes
                            : _displayCategory(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        style:
                            isTablet
                                ? AppTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                )
                                : AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xxs + 2),

                      // Subtitle: Category + DateTime compact
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs + 2,
                        alignment:
                            isRTL ? WrapAlignment.end : WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Pill(
                            text: _displayCategory(),
                            icon: Icons.local_offer_outlined,
                          ),
                          Text(
                            _compactDateTime(),
                            style: (isTablet
                                    ? AppTypography.bodyMedium
                                    : AppTypography.bodySmall)
                                .copyWith(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),

                      // Optional: Vendor / Invoice (if your model has them)
                      // Uncomment if available in Expense model:
                      /*
                      if ((expense.vendorName ?? '').isNotEmpty ||
                          (expense.invoiceNumber ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          [
                            if ((expense.vendorName ?? '').isNotEmpty) expense.vendorName,
                            if ((expense.invoiceNumber ?? '').isNotEmpty) '#${expense.invoiceNumber}',
                          ].whereType<String>().join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                      */

                      // Photo preview (small) if exists
                      if (expense.photoPath != null) ...[
                        const SizedBox(height: 10),
                        _PhotoMiniPreview(
                          path: expense.photoPath!,
                          height: isTablet ? 86 : 72,
                          radius: isTablet ? 12 : 10,
                          isRTL: isRTL,
                          onTap: () => _showFullScreenImage(context),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: isTablet ? AppSpacing.sm : AppSpacing.xs + 2),

                // Right side: Amount + delete button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currencySymbol${expense.amount.toStringAsFixed(2)}',
                      style: (isTablet
                              ? AppTypography.amountSmall
                              : AppTypography.amountSmall.copyWith(
                                fontSize: 15,
                              ))
                          .copyWith(
                            fontWeight: FontWeight.w800,
                            color: _amountColor(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, userState) {
                        final canDelete =
                            PermissionService.canDeleteSpecificExpense(
                              userState.currentUser,
                              expense.employeeId ?? '',
                            );
                        if (!canDelete) return const SizedBox.shrink();
                        return _IconAction(
                          icon: Icons.delete_outline,
                          tooltip: isRTL ? 'حذف' : 'Delete',
                          onPressed: () => _showDeleteConfirmation(context),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    if (expense.photoPath == null || !File(expense.photoPath!).existsSync()) {
      return;
    }

    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.file(
                      File(expense.photoPath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: isTablet ? AppSpacing.xl : AppSpacing.md,
                  right: isTablet ? AppSpacing.xl : AppSpacing.md,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: isTablet ? 40 : 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isRTL ? 'حذف المصروف' : 'Delete Expense',
            style:
                isTablet
                    ? AppTypography.headlineMedium
                    : AppTypography.headlineSmall,
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من رغبتك في حذف هذا المصروف؟'
                : 'Are you sure you want to delete this expense?',
            style:
                isTablet ? AppTypography.bodyLarge : AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style:
                    isTablet
                        ? AppTypography.bodyLarge
                        : AppTypography.bodyMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppSpacing.xl : AppSpacing.md,
                  vertical: isTablet ? AppSpacing.sm : AppSpacing.xs,
                ),
              ),
              child: Text(
                isRTL ? 'حذف' : 'Delete',
                style:
                    isTablet
                        ? AppTypography.bodyLarge
                        : AppTypography.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(expense: expense),
      ),
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  final IconData icon;
  final double size;

  const _CategoryAvatar({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(icon, color: primaryColor, size: size * 0.55),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Pill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: (isDark ? Colors.grey : Colors.grey).withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.sm + 2,
            color:
                isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          Text(
            text,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;
    return InkResponse(
      onTap: onPressed,
      radius: 22,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxs + 2),
          decoration: BoxDecoration(
            color: errorColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          ),
          child: Icon(icon, color: errorColor.withOpacity(0.7), size: 22),
        ),
      ),
    );
  }
}

class _PhotoMiniPreview extends StatelessWidget {
  final String path;
  final double height;
  final double radius;
  final bool isRTL;
  final VoidCallback onTap;

  const _PhotoMiniPreview({
    required this.path,
    required this.height,
    required this.radius,
    required this.isRTL,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exists = File(path).existsSync();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: exists ? onTap : null,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          color:
              isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child:
              exists
                  ? Image.file(File(path), fit: BoxFit.cover)
                  : Center(
                    child: Text(
                      isRTL ? 'الصورة غير متوفرة' : 'Image not available',
                      style: AppTypography.bodySmall.copyWith(
                        color:
                            isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
