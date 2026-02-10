// Expense Details - Basic Details Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/utils/date_time_utils.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class ExpenseBasicDetailsCard extends StatelessWidget {
  final Expense expense;
  final bool isRTL;

  const ExpenseBasicDetailsCard({
    super.key,
    required this.expense,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      context,
      title: isRTL ? 'التفاصيل' : 'Details',
      icon: Icons.description,
      child: Column(
        children: [
          // التاريخ الكامل
          _buildDetailRow(
            context,
            icon: Icons.calendar_today,
            label: isRTL ? 'التاريخ' : 'Date',
            value: DateTimeUtils.formatExpenseDateDetails(
              expenseDate: expense.date,
              isRTL: isRTL,
            ),
            isRTL: isRTL,
          ),
          // const Divider(height: 16),

          // // الوقت
          // _buildDetailRow(
          //   context,
          //   icon: Icons.access_time,
          //   label: isRTL ? 'الوقت' : 'Time',
          //   value: DateFormat(
          //     'hh:mm a',
          //     isRTL ? 'ar' : 'en',
          //   ).format(expense.date),
          //   isRTL: isRTL,
          // ),

          // الملاحظات
          if (expense.notes.isNotEmpty) ...[
            const Divider(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.notes,
              label: isRTL ? 'الملاحظات' : 'Notes',
              value: expense.notes,
              isRTL: isRTL,
            ),
          ],

          // API Timestamps (if available)
          if (expense.createdAt != null) ...[
            const Divider(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.add_circle_outline,
              label: isRTL ? 'تاريخ الإنشاء' : 'Created At',
              value: DateTimeUtils.formatTimestampDetails(
                timestamp: expense.createdAt!,
                isRTL: isRTL,
              ),
              isRTL: isRTL,
            ),
          ],
          if (expense.updatedAt != null && expense.updatedAt != expense.createdAt) ...[
            const Divider(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.edit_outlined,
              label: isRTL ? 'آخر تحديث' : 'Last Updated',
              value: DateTimeUtils.formatTimestampDetails(
                timestamp: expense.updatedAt!,
                isRTL: isRTL,
              ),
              isRTL: isRTL,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isRTL,
    Color? valueColor,
  }) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: settings.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          settings.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          valueColor ??
                          (settings.isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
