import 'package:expense_tracker/features/users/data/models/user.dart';

/// خدمة إدارة الصلاحيات
/// تتعامل مع التحقق من الصلاحيات والأذونات
class PermissionService {
  /// التحقق من صلاحية إدارة المستخدمين (Owner only)
  static bool canManageUsers(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner;
  }

  /// التحقق من صلاحية عرض قائمة المستخدمين (Owner و Accountant)
  static bool canViewUsers(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية إدارة المصروفات
  static bool canManageExpenses(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية إضافة مصروفات
  static bool canAddExpenses(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner ||
        user.role == UserRole.accountant ||
        user.role == UserRole.employee;
  }

  /// التحقق من صلاحية عرض التقارير
  static bool canViewReports(User? user) {
    if (user == null || !user.isActive) return false;
    return true; // جميع المستخدمين يمكنهم عرض التقارير
  }

  /// التحقق من صلاحية الموافقة على المصروفات
  static bool canApproveExpenses(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية تعديل المصروفات
  static bool canEditExpenses(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية حذف المصروفات
  /// Only owner can delete expenses (accountant can view + create + edit, but not delete)
  static bool canDeleteExpenses(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner;
  }

  /// التحقق من صلاحية إدارة الميزانيات
  static bool canManageBudgets(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية إدارة الحسابات
  static bool canManageAccounts(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية إدارة الإعدادات
  static bool canManageSettings(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner;
  }

  /// التحقق من صلاحية تصدير البيانات
  static bool canExportData(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية عرض التقارير المالية المتقدمة
  static bool canViewAdvancedReports(User? user) {
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }

  /// التحقق من صلاحية تعديل مصروف معين (المالك أو المحاسب أو صاحب المصروف)
  static bool canEditSpecificExpense(User? user, String expenseEmployeeId) {
    if (user == null || !user.isActive) return false;

    // المدير والمحاسب يمكنهم تعديل جميع المصروفات
    if (user.role == UserRole.owner || user.role == UserRole.accountant) {
      return true;
    }

    // الموظف يمكنه تعديل مصروفاته فقط
    if (user.role == UserRole.employee) {
      return user.employeeId == expenseEmployeeId;
    }

    return false;
  }

  /// التحقق من صلاحية حذف مصروف معين
  /// Only owner can delete expenses (accountant can view + create + edit, but not delete)
  static bool canDeleteSpecificExpense(User? user, String expenseEmployeeId) {
    if (user == null || !user.isActive) return false;

    // Only owner can delete expenses
    if (user.role == UserRole.owner) {
      return true;
    }

    // Accountant, employee, and auditor cannot delete expenses
    return false;
  }

  /// الحصول على قائمة الصلاحيات للمستخدم
  static List<String> getUserPermissions(User? user) {
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

  /// الحصول على وصف الصلاحيات باللغة العربية
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

  /// التحقق من أن المستخدم له صلاحية معينة
  static bool hasPermission(User? user, String permission) {
    final permissions = getUserPermissions(user);
    return permissions.contains(permission);
  }

  /// الحصول على مستوى الصلاحيات للمستخدم
  static int getPermissionLevel(User? user) {
    if (user == null || !user.isActive) return 0;
    return user.role.permissionLevel;
  }

  /// التحقق من أن المستخدم له مستوى صلاحيات أعلى أو مساوي
  static bool hasPermissionLevel(User? user, UserRole requiredRole) {
    if (user == null || !user.isActive) return false;
    return user.role.permissionLevel <= requiredRole.permissionLevel;
  }

  /// الحصول على الأدوار التي يمكن للمستخدم الحالي إدارتها
  static List<UserRole> getManageableRoles(User? currentUser) {
    if (currentUser == null || !currentUser.isActive) return [];

    switch (currentUser.role) {
      case UserRole.owner:
        return UserRole.values; // المدير يمكنه إدارة جميع الأدوار
      case UserRole.accountant:
        return [
          UserRole.employee,
          UserRole.auditor,
        ]; // المحاسب يمكنه إدارة الموظفين والمراجعين
      case UserRole.employee:
      case UserRole.auditor:
        return []; // الموظف والمراجع لا يمكنهما إدارة أي أدوار
    }
  }

  /// التحقق من أن المستخدم يمكنه تغيير دور مستخدم آخر
  static bool canChangeUserRole(
    User? currentUser,
    User targetUser,
    UserRole newRole,
  ) {
    if (currentUser == null || !currentUser.isActive) return false;

    // لا يمكن تغيير دور المدير العام
    if (targetUser.role == UserRole.owner) return false;

    // لا يمكن تغيير الدور إلى مدير عام إلا إذا كان المستخدم الحالي مدير
    if (newRole == UserRole.owner && currentUser.role != UserRole.owner) {
      return false;
    }

    final manageableRoles = getManageableRoles(currentUser);
    return manageableRoles.contains(newRole);
  }

  /// الحصول على الحد الأقصى للمبلغ الذي يمكن للمستخدم إضافته بدون موافقة
  static double getMaxAmountWithoutApproval(User? user) {
    if (user == null || !user.isActive) return 0.0;

    switch (user.role) {
      case UserRole.owner:
        return double.infinity; // المدير لا يحتاج موافقة
      case UserRole.accountant:
        return 1000.0; // المحاسب يمكنه إضافة حتى 1000 بدون موافقة
      case UserRole.employee:
        return 100.0; // الموظف يمكنه إضافة حتى 100 بدون موافقة
      case UserRole.auditor:
        return 0.0; // المراجع لا يمكنه إضافة مصروفات
    }
  }

  /// التحقق من أن المبلغ يحتاج موافقة
  static bool requiresApproval(User? user, double amount) {
    if (user == null || !user.isActive) return true;

    final maxAmount = getMaxAmountWithoutApproval(user);
    return amount > maxAmount;
  }

  /// الحصول على الأدوار التي يمكنها الموافقة على مبلغ معين
  static List<UserRole> getApprovalRoles(double amount) {
    if (amount <= 100.0) {
      return [UserRole.accountant, UserRole.owner];
    } else if (amount <= 1000.0) {
      return [UserRole.accountant, UserRole.owner];
    } else {
      return [UserRole.owner]; // المبالغ الكبيرة تحتاج موافقة المدير فقط
    }
  }

  /// التحقق من أن المستخدم يمكنه الموافقة على مبلغ معين
  static bool canApproveAmount(User? user, double amount) {
    if (user == null || !user.isActive) return false;

    final approvalRoles = getApprovalRoles(amount);
    return approvalRoles.contains(user.role);
  }
}
