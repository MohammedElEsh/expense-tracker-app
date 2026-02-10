// ✅ Clean Architecture - BLoC Events
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل جميع المستخدمين
class LoadUsers extends UserEvent {
  const LoadUsers();
}

/// إضافة مستخدم جديد
class AddUser extends UserEvent {
  final User user;

  const AddUser(this.user);

  @override
  List<Object> get props => [user];
}

/// تحديث مستخدم موجود
class UpdateUser extends UserEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object> get props => [user];
}

/// حذف مستخدم
class DeleteUser extends UserEvent {
  final String userId;

  const DeleteUser(this.userId);

  @override
  List<Object> get props => [userId];
}

/// تفعيل/إلغاء تفعيل مستخدم
class ToggleUserStatus extends UserEvent {
  final String userId;
  final bool isActive;

  const ToggleUserStatus(this.userId, this.isActive);

  @override
  List<Object> get props => [userId, isActive];
}

/// تحديث آخر تسجيل دخول للمستخدم
class UpdateLastLogin extends UserEvent {
  final String userId;

  const UpdateLastLogin(this.userId);

  @override
  List<Object> get props => [userId];
}

/// تغيير دور المستخدم
class ChangeUserRole extends UserEvent {
  final String userId;
  final UserRole newRole;

  const ChangeUserRole(this.userId, this.newRole);

  @override
  List<Object> get props => [userId, newRole];
}

/// البحث في المستخدمين
class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

/// تصفية المستخدمين حسب الدور
class FilterUsersByRole extends UserEvent {
  final UserRole? role;

  const FilterUsersByRole(this.role);

  @override
  List<Object?> get props => [role];
}

/// تصفية المستخدمين حسب القسم
class FilterUsersByDepartment extends UserEvent {
  final String? department;

  const FilterUsersByDepartment(this.department);

  @override
  List<Object?> get props => [department];
}

/// مسح جميع الفلاتر
class ClearUserFilters extends UserEvent {
  const ClearUserFilters();
}

/// تعيين المستخدم الحالي
class SetCurrentUser extends UserEvent {
  final User? user;

  const SetCurrentUser(this.user);

  @override
  List<Object?> get props => [user];
}

/// تسجيل خروج المستخدم الحالي
class LogoutUser extends UserEvent {
  const LogoutUser();
}
