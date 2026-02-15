import 'package:expense_tracker/features/users/data/models/user.dart' as data;
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart' as domain;

/// User/role permission checks. Lives in users feature (not core).
class PermissionService {
  static bool canManageUsersEntity(UserEntity? user) {
    if (user == null || !user.isActive) return false;
    return user.role == domain.UserRole.owner;
  }

  static bool canViewUsersEntity(UserEntity? user) {
    if (user == null || !user.isActive) return false;
    return user.role == domain.UserRole.owner || user.role == domain.UserRole.accountant;
  }

  static bool canManageUsers(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner;
  }

  static bool canViewUsers(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canManageExpensesEntity(UserEntity? user) {
    if (user == null || !user.isActive) return false;
    return user.role == domain.UserRole.owner || user.role == domain.UserRole.accountant;
  }

  static bool canManageExpenses(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canAddExpenses(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner ||
        user.role == data.UserRole.accountant ||
        user.role == data.UserRole.employee;
  }

  static bool canViewReports(data.User? user) {
    if (user == null || !user.isActive) return false;
    return true;
  }

  static bool canApproveExpenses(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canEditExpenses(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canDeleteExpenses(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner;
  }

  static bool canManageBudgetsEntity(UserEntity? user) {
    if (user == null || !user.isActive) return false;
    return user.role == domain.UserRole.owner || user.role == domain.UserRole.accountant;
  }

  static bool canManageBudgets(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canManageAccounts(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canManageSettings(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner;
  }

  static bool canExportData(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canViewAdvancedReportsEntity(UserEntity? user) {
    if (user == null || !user.isActive) return false;
    return user.role == domain.UserRole.owner || user.role == domain.UserRole.accountant;
  }

  static bool canViewAdvancedReports(data.User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner || user.role == data.UserRole.accountant;
  }

  static bool canEditSpecificExpenseEntity(UserEntity? user, String expenseEmployeeId) {
    if (user == null || !user.isActive) return false;
    if (user.role == domain.UserRole.owner || user.role == domain.UserRole.accountant) {
      return true;
    }
    if (user.role == domain.UserRole.employee) {
      return user.employeeId == expenseEmployeeId;
    }
    return false;
  }

  static bool canDeleteSpecificExpenseEntity(UserEntity? user, String expenseEmployeeId) {
    if (user == null || !user.isActive) return false;
    return user.role == domain.UserRole.owner;
  }

  static bool canEditSpecificExpense(data.User? user, String expenseEmployeeId) {
    if (user == null || !user.isActive) return false;
    if (user.role == data.UserRole.owner || user.role == data.UserRole.accountant) {
      return true;
    }
    if (user.role == data.UserRole.employee) {
      return user.employeeId == expenseEmployeeId;
    }
    return false;
  }

  static bool canDeleteSpecificExpense(data.User? user, String expenseEmployeeId) {
    if (user == null || !user.isActive) return false;
    return user.role == data.UserRole.owner;
  }

  static List<String> getUserPermissions(data.User? user) {
    if (user == null || !user.isActive) return [];
    final permissions = <String>[];
    if (canManageUsers(user)) permissions.add('manage_users');
    if (canManageExpenses(user)) permissions.add('manage_expenses');
    if (canAddExpenses(user)) permissions.add('add_expenses');
    if (canViewReports(user)) permissions.add('view_reports');
    if (canApproveExpenses(user)) permissions.add('approve_expenses');
    if (canEditExpenses(user)) permissions.add('edit_expenses');
    if (canDeleteExpenses(user)) permissions.add('delete_expenses');
    if (canManageBudgets(user)) permissions.add('manage_budgets');
    if (canManageAccounts(user)) permissions.add('manage_accounts');
    if (canManageSettings(user)) permissions.add('manage_settings');
    if (canExportData(user)) permissions.add('export_data');
    if (canViewAdvancedReports(user)) permissions.add('view_advanced_reports');
    return permissions;
  }

  static Map<String, String> getPermissionDescriptions(bool isRTL) {
    if (isRTL) {
      return {
        'manage_users': 'إدارة المستخدمين',
        'manage_expenses': 'إدارة المصروفات',
        'add_expenses': 'إضافة مصروفات',
        'view_reports': 'عرض التقارير',
        'approve_expenses': 'الموافقة على المصروفات',
        'edit_expenses': 'تعديل المصروفات',
        'delete_expenses': 'حذف المصروفات',
        'manage_budgets': 'إدارة الميزانيات',
        'manage_accounts': 'إدارة الحسابات',
        'manage_settings': 'إدارة الإعدادات',
        'export_data': 'تصدير البيانات',
        'view_advanced_reports': 'عرض التقارير المتقدمة',
      };
    } else {
      return {
        'manage_users': 'Manage Users',
        'manage_expenses': 'Manage Expenses',
        'add_expenses': 'Add Expenses',
        'view_reports': 'View Reports',
        'approve_expenses': 'Approve Expenses',
        'edit_expenses': 'Edit Expenses',
        'delete_expenses': 'Delete Expenses',
        'manage_budgets': 'Manage Budgets',
        'manage_accounts': 'Manage Accounts',
        'manage_settings': 'Manage Settings',
        'export_data': 'Export Data',
        'view_advanced_reports': 'View Advanced Reports',
      };
    }
  }

  static bool hasPermission(data.User? user, String permission) {
    return getUserPermissions(user).contains(permission);
  }

  static int getPermissionLevel(data.User? user) {
    if (user == null || !user.isActive) return 0;
    return user.role.permissionLevel;
  }

  static bool hasPermissionLevel(data.User? user, data.UserRole requiredRole) {
    if (user == null || !user.isActive) return false;
    return user.role.permissionLevel <= requiredRole.permissionLevel;
  }

  static List<data.UserRole> getManageableRoles(data.User? currentUser) {
    if (currentUser == null || !currentUser.isActive) return [];
    switch (currentUser.role) {
      case data.UserRole.owner:
        return data.UserRole.values;
      case data.UserRole.accountant:
        return [data.UserRole.employee, data.UserRole.auditor];
      case data.UserRole.employee:
      case data.UserRole.auditor:
        return [];
    }
  }

  static bool canChangeUserRole(data.User? currentUser, data.User targetUser, data.UserRole newRole) {
    if (currentUser == null || !currentUser.isActive) return false;
    if (targetUser.role == data.UserRole.owner) return false;
    if (newRole == data.UserRole.owner && currentUser.role != data.UserRole.owner) return false;
    return getManageableRoles(currentUser).contains(newRole);
  }

  static double getMaxAmountWithoutApproval(data.User? user) {
    if (user == null || !user.isActive) return 0.0;
    switch (user.role) {
      case data.UserRole.owner:
        return double.infinity;
      case data.UserRole.accountant:
        return 1000.0;
      case data.UserRole.employee:
        return 100.0;
      case data.UserRole.auditor:
        return 0.0;
    }
  }

  static bool requiresApproval(data.User? user, double amount) {
    if (user == null || !user.isActive) return true;
    return amount > getMaxAmountWithoutApproval(user);
  }

  static List<data.UserRole> getApprovalRoles(double amount) {
    if (amount <= 100.0) return [data.UserRole.accountant, data.UserRole.owner];
    if (amount <= 1000.0) return [data.UserRole.accountant, data.UserRole.owner];
    return [data.UserRole.owner];
  }

  static bool canApproveAmount(data.User? user, double amount) {
    if (user == null || !user.isActive) return false;
    return getApprovalRoles(amount).contains(user.role);
  }
}
