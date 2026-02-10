// ✅ Clean Architecture - BLoC State
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

class UserState extends Equatable {
  final List<User> users;
  final User? currentUser;
  final List<User> filteredUsers;
  final String searchQuery;
  final UserRole? selectedRole;
  final String? selectedDepartment;
  final bool isLoading;
  final String? error;

  const UserState({
    this.users = const [],
    this.currentUser,
    this.filteredUsers = const [],
    this.searchQuery = '',
    this.selectedRole,
    this.selectedDepartment,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
    users,
    currentUser,
    filteredUsers,
    searchQuery,
    selectedRole,
    selectedDepartment,
    isLoading,
    error,
  ];

  UserState copyWith({
    List<User>? users,
    User? currentUser,
    List<User>? filteredUsers,
    String? searchQuery,
    UserRole? selectedRole,
    String? selectedDepartment,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserState(
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// الحصول على المستخدمين النشطين فقط
  List<User> get activeUsers {
    return users.where((user) => user.isActive).toList();
  }

  /// الحصول على المستخدمين حسب الدور
  List<User> getUsersByRole(UserRole role) {
    return users.where((user) => user.role == role).toList();
  }

  /// الحصول على المستخدمين حسب القسم
  List<User> getUsersByDepartment(String department) {
    return users.where((user) => user.department == department).toList();
  }

  /// الحصول على جميع الأقسام
  List<String> get allDepartments {
    final departments =
        users
            .where(
              (user) => user.department != null && user.department!.isNotEmpty,
            )
            .map((user) => user.department!)
            .toSet()
            .toList();
    departments.sort();
    return departments;
  }

  /// التحقق من وجود مستخدم بالبريد الإلكتروني
  bool hasUserWithEmail(String email) {
    return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  /// الحصول على المستخدم بالمعرف
  User? getUserById(String userId) {
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على المستخدم بالبريد الإلكتروني
  User? getUserByEmail(String email) {
    try {
      return users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// التحقق من أن المستخدم الحالي له صلاحية معينة
  bool currentUserHasPermission(UserRole requiredRole) {
    return currentUser?.hasPermission(requiredRole) ?? false;
  }

  /// التحقق من أن المستخدم الحالي مدير
  bool get isCurrentUserOwner => currentUser?.isOwner ?? false;

  /// التحقق من أن المستخدم الحالي محاسب
  bool get isCurrentUserAccountant => currentUser?.isAccountant ?? false;

  /// التحقق من أن المستخدم الحالي موظف
  bool get isCurrentUserEmployee => currentUser?.isEmployee ?? false;

  /// التحقق من أن المستخدم الحالي مراجع
  bool get isCurrentUserAuditor => currentUser?.isAuditor ?? false;

  /// التحقق من أن المستخدم الحالي يمكنه إدارة المستخدمين
  bool get canCurrentUserManageUsers => currentUser?.canManageUsers ?? false;

  /// التحقق من أن المستخدم الحالي يمكنه إدارة المصروفات
  bool get canCurrentUserManageExpenses =>
      currentUser?.canManageExpenses ?? false;

  /// التحقق من أن المستخدم الحالي يمكنه إضافة مصروفات
  bool get canCurrentUserAddExpenses => currentUser?.canAddExpenses ?? false;

  /// التحقق من أن المستخدم الحالي يمكنه عرض التقارير
  bool get canCurrentUserViewReports => currentUser?.canViewReports ?? false;

  /// التحقق من أن المستخدم الحالي يمكنه الموافقة على المصروفات
  bool get canCurrentUserApproveExpenses =>
      currentUser?.canApproveExpenses ?? false;

  /// إحصائيات المستخدمين
  Map<String, int> get userStatistics {
    final stats = <String, int>{};

    for (final role in UserRole.values) {
      stats[role.name] = users.where((user) => user.role == role).length;
    }

    stats['total'] = users.length;
    stats['active'] = activeUsers.length;
    stats['inactive'] = users.length - activeUsers.length;

    return stats;
  }

  /// الحصول على المستخدمين المفلترين مع البحث
  List<User> get effectiveUsers {
    List<User> result = filteredUsers.isNotEmpty ? filteredUsers : users;

    if (searchQuery.isNotEmpty) {
      result =
          result.where((user) {
            return user.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (user.department?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }

    return result;
  }
}
