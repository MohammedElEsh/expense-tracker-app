import 'dart:io';

import 'package:expense_tracker/core/utils/date_time_utils.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_details_screen.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/services/permission_service.dart';
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

  Color _amountColor() => Colors.red;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        onTap: () => _navigateToDetails(context),
        child: Container(
          margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
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
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Icon
                _CategoryAvatar(
                  icon: getCategoryIcon(expense.category),
                  size: isTablet ? 48 : 40,
                ),

                SizedBox(width: isTablet ? 14 : 12),

                // Middle Content
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // Title (notes or category)
                      Text(
                        expense.notes.isNotEmpty ? expense.notes : _displayCategory(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle: Category + DateTime compact
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: isRTL ? WrapAlignment.end : WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Pill(
                            text: _displayCategory(),
                            icon: Icons.local_offer_outlined,
                          ),
                          Text(
                            _compactDateTime(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
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

                SizedBox(width: isTablet ? 12 : 10),

                // Right side: Amount + delete button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currencySymbol${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 15,
                        fontWeight: FontWeight.w800,
                        color: _amountColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        final canDelete = PermissionService.canDeleteSpecificExpense(
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
      builder: (context) => Dialog(
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
              top: isTablet ? 24 : 16,
              right: isTablet ? 24 : 16,
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
            style: TextStyle(fontSize: isTablet ? 20 : 18),
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من رغبتك في حذف هذا المصروف؟'
                : 'Are you sure you want to delete this expense?',
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
              ),
              child: Text(
                isRTL ? 'حذف' : 'Delete',
                style: TextStyle(fontSize: isTablet ? 16 : 14),
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
    final bg = Colors.blue.withOpacity(0.10);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(icon, color: Colors.blue, size: size * 0.55),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Pill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
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
    return InkResponse(
      onTap: onPressed,
      radius: 22,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.red[400], size: 22),
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

    return GestureDetector(
      onTap: exists ? onTap : null,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: exists
              ? Image.file(File(path), fit: BoxFit.cover)
              : Center(
            child: Text(
              isRTL ? 'الصورة غير متوفرة' : 'Image not available',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
