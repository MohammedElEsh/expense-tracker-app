import 'package:flutter/material.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';

extension UserRoleDisplay on UserRole {
  String getDisplayName(bool isRTL) {
    if (isRTL) {
      switch (this) {
        case UserRole.owner:
          return 'مدير عام';
        case UserRole.accountant:
          return 'محاسب';
        case UserRole.employee:
          return 'موظف';
        case UserRole.auditor:
          return 'مراجع';
      }
    }
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.employee:
        return 'Employee';
      case UserRole.auditor:
        return 'Auditor';
    }
  }

  String getDescription(bool isRTL) {
    if (isRTL) {
      switch (this) {
        case UserRole.owner:
          return 'صلاحيات كاملة على جميع الميزات والإعدادات';
        case UserRole.accountant:
          return 'إدارة المصروفات والميزانيات والتقارير المالية';
        case UserRole.employee:
          return 'إضافة مصروفات تحتاج موافقة';
        case UserRole.auditor:
          return 'عرض التقارير والإحصائيات فقط';
      }
    }
    switch (this) {
      case UserRole.owner:
        return 'Full access to all features and settings';
      case UserRole.accountant:
        return 'Manage expenses, budgets, and financial reports';
      case UserRole.employee:
        return 'Add expenses that require approval';
      case UserRole.auditor:
        return 'View reports and analytics only';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return Icons.admin_panel_settings;
      case UserRole.accountant:
        return Icons.account_balance;
      case UserRole.employee:
        return Icons.person;
      case UserRole.auditor:
        return Icons.visibility;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.owner:
        return const Color(0xFF6A1B9A);
      case UserRole.accountant:
        return const Color(0xFF00695C);
      case UserRole.employee:
        return const Color(0xFF33691E);
      case UserRole.auditor:
        return const Color(0xFFB71C1C);
    }
  }
}
