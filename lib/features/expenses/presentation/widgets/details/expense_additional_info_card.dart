// Expense Details - Additional Info Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class ExpenseAdditionalInfoCard extends StatelessWidget {
  final Expense expense;
  final bool isRTL;
  final String? employeeName;
  final String? projectName;
  final String? vendorName;

  const ExpenseAdditionalInfoCard({
    super.key,
    required this.expense,
    required this.isRTL,
    this.employeeName,
    this.projectName,
    this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    // عرض المعلومات الإضافية إذا كان هناك أي بيانات إضافية
    final hasAdditionalInfo =
        employeeName != null ||
        projectName != null ||
        vendorName != null ||
        (expense.department != null && expense.department!.isNotEmpty) ||
        (expense.invoiceNumber != null && expense.invoiceNumber!.isNotEmpty) ||
        (expense.employeeId != null && expense.employeeId!.isNotEmpty) ||
        (expense.projectId != null && expense.projectId!.isNotEmpty) ||
        (expense.vendorName != null && expense.vendorName!.isNotEmpty);

    if (!hasAdditionalInfo) return const SizedBox.shrink();

    return _buildCard(
      context,
      title: isRTL ? 'معلومات إضافية' : 'Additional Info',
      icon: Icons.info_outline,
      child: Column(
        children: [
          // عرض الموظف (اسم أو ID)
          if (expense.employeeId != null && expense.employeeId!.isNotEmpty) ...[
            _buildDetailRow(
              context,
              icon: Icons.person,
              label: isRTL ? 'أضافه' : 'Added By',
              value: _getEmployeeDisplayName(),
              isRTL: isRTL,
            ),
            const Divider(height: 16),
          ],
          // عرض المشروع (اسم أو ID)
          if (expense.projectId != null && expense.projectId!.isNotEmpty) ...[
            _buildDetailRow(
              context,
              icon: Icons.folder,
              label: isRTL ? 'المشروع' : 'Project',
              value: _getProjectDisplayName(),
              isRTL: isRTL,
            ),
            const Divider(height: 16),
          ],
          // عرض المورد
          if (expense.vendorName != null && expense.vendorName!.isNotEmpty) ...[
            _buildDetailRow(
              context,
              icon: Icons.store,
              label: isRTL ? 'المورد' : 'Vendor',
              value: expense.vendorName!,
              isRTL: isRTL,
            ),
            const Divider(height: 16),
          ],
          // عرض القسم
          if (expense.department != null && expense.department!.isNotEmpty) ...[
            _buildDetailRow(
              context,
              icon: Icons.apartment,
              label: isRTL ? 'القسم' : 'Department',
              value: expense.department!,
              isRTL: isRTL,
            ),
            const Divider(height: 16),
          ],
          // عرض رقم الفاتورة
          if (expense.invoiceNumber != null &&
              expense.invoiceNumber!.isNotEmpty)
            _buildDetailRow(
              context,
              icon: Icons.receipt_long,
              label: isRTL ? 'رقم الفاتورة' : 'Invoice Number',
              value: expense.invoiceNumber!,
              isRTL: isRTL,
            ),
        ],
      ),
    );
  }

  String _getEmployeeDisplayName() {
    if (expense.employeeName != null && expense.employeeName!.isNotEmpty) {
      return expense.employeeName!;
    }
    if (expense.employeeId != null && expense.employeeId!.isNotEmpty) {
      return 'ID: ${expense.employeeId!}';
    }
    return 'غير محدد';
  }

  String _getProjectDisplayName() {
    if (projectName != null && projectName!.isNotEmpty) {
      return projectName!;
    }
    if (expense.projectId != null && expense.projectId!.isNotEmpty) {
      return expense.projectId!;
    }
    return 'غير محدد';
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
    return BlocBuilder<SettingsCubit, SettingsState>(
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
