// ✅ Clean Architecture - Presentation Cubit
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/users/data/datasources/user_service.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  static const String usersBoxName = 'users';
  static const String _currentUserKey = 'current_user';

  UserCubit() : super(const UserState());

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // تحميل المستخدمين من Hive
      final users = <User>[];

      // تحميل المستخدم الحالي من Hive
      final currentUserBox = await Hive.openBox(_currentUserKey);
      final currentUserId = currentUserBox.get('id');
      User? currentUser;
      if (currentUserId != null) {
        try {
          currentUser = users.firstWhere((user) => user.id == currentUserId);
        } catch (e) {
          currentUser = null;
        }
      } else {
        currentUser = null;
      }

      emit(
        state.copyWith(
          users: users,
          currentUser: currentUser,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'Failed to load users: $error'),
      );
    }
  }

  Future<void> addUser(User user) async {
    try {
      await UserService.updateUser(user);

      final updatedUsers = List<User>.from(state.users)..add(user);

      emit(state.copyWith(users: updatedUsers));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to add user: $error'));
    }
  }

  Future<void> updateUser(User user) async {
    try {
      // تحديث المستخدم في قاعدة البيانات
      await UserService.updateUser(user);

      // تحديث قائمة المستخدمين في الـ state
      final updatedUsers =
          state.users.map((u) {
            return u.id == user.id ? user : u;
          }).toList();

      // تحديث المستخدم الحالي إذا كان هو المحدث
      final updatedCurrentUser =
          state.currentUser?.id == user.id ? user : state.currentUser;

      emit(
        state.copyWith(users: updatedUsers, currentUser: updatedCurrentUser),
      );
    } catch (error) {
      emit(state.copyWith(error: 'Failed to update user: $error'));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await UserService.deleteUser(userId);

      final updatedUsers =
          state.users.where((user) => user.id != userId).toList();

      // إذا كان المستخدم المحذوف هو المستخدم الحالي، قم بتسجيل الخروج
      final updatedCurrentUser =
          state.currentUser?.id == userId ? null : state.currentUser;

      emit(
        state.copyWith(users: updatedUsers, currentUser: updatedCurrentUser),
      );
    } catch (error) {
      emit(state.copyWith(error: 'Failed to delete user: $error'));
    }
  }

  Future<void> toggleUserStatus(String userId) async {
    try {
      final updatedUser = await UserService.toggleUserStatus(userId);
      updateUser(updatedUser);
    } catch (error) {
      emit(state.copyWith(error: 'Failed to toggle user status: $error'));
    }
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      final user = state.getUserById(userId);
      if (user == null) return;

      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await UserService.updateUser(updatedUser);
      updateUser(updatedUser);
    } catch (error) {
      emit(state.copyWith(error: 'Failed to update last login: $error'));
    }
  }

  Future<void> changeUserRole(String userId, UserRole newRole) async {
    try {
      final user = state.getUserById(userId);
      if (user == null) return;

      // تحديث الدور عبر REST API
      await serviceLocator.authRemoteDataSource.updateUserRole(
        userId,
        newRole.name,
      );

      final updatedUser = user.copyWith(role: newRole);
      await UserService.updateUser(updatedUser);
      updateUser(updatedUser);
    } catch (error) {
      emit(state.copyWith(error: 'Failed to change user role: $error'));
    }
  }

  void searchUsers(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterUsersByRole(UserRole? role) {
    List<User> filteredUsers = state.users;

    if (role != null) {
      filteredUsers = filteredUsers.where((user) => user.role == role).toList();
    }

    emit(state.copyWith(selectedRole: role, filteredUsers: filteredUsers));
  }

  void filterUsersByDepartment(String? department) {
    List<User> filteredUsers = state.users;

    if (department != null) {
      filteredUsers =
          filteredUsers.where((user) => user.department == department).toList();
    }

    emit(
      state.copyWith(
        selectedDepartment: department,
        filteredUsers: filteredUsers,
      ),
    );
  }

  void clearUserFilters() {
    emit(
      state.copyWith(
        searchQuery: '',
        selectedRole: null,
        selectedDepartment: null,
        filteredUsers: [],
      ),
    );
  }

  Future<void> setCurrentUser(User? user) async {
    try {
      // Check if user or role changed
      final previousUser = state.currentUser;
      final newUser = user;

      if (newUser != null) {
        final currentUserBox = await Hive.openBox(_currentUserKey);
        await currentUserBox.put('id', newUser.id);

        // Check if user or role changed (for context clearing)
        final userIdChanged = previousUser?.id != newUser.id;
        final roleChanged = previousUser?.role != newUser.role;

        if (userIdChanged || roleChanged) {
          debugPrint(
            '🔄 User context changed - User: $userIdChanged, Role: $roleChanged',
          );
          debugPrint(
            '   Previous: ${previousUser?.id ?? 'null'} (${previousUser?.role.name ?? 'null'})',
          );
          debugPrint('   New: ${newUser.id} (${newUser.role.name})');
        }

        // تحديث آخر تسجيل دخول
        updateLastLogin(newUser.id);
      } else {
        final currentUserBox = await Hive.openBox(_currentUserKey);
        await currentUserBox.delete('id');
      }

      emit(state.copyWith(currentUser: user));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to set current user: $error'));
    }
  }

  Future<void> logoutUser() async {
    try {
      // Clear user context before logout
      userContextManager.clearContext();

      final currentUserBox = await Hive.openBox(_currentUserKey);
      await currentUserBox.delete('id');

      emit(state.copyWith(currentUser: null));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to logout user: $error'));
    }
  }

  /// إنشاء مستخدم افتراضي (مدير عام)
  Future<void> createDefaultOwner() async {
    final defaultOwner = User(
      id: 'default_owner',
      name: 'مدير النظام',
      email: 'admin@company.com',
      role: UserRole.owner,
      department: 'الإدارة',
      isActive: true,
      createdAt: DateTime.now(),
    );

    addUser(defaultOwner);
    setCurrentUser(defaultOwner);
  }

  /// التحقق من وجود مستخدمين في النظام
  bool get hasUsers => state.users.isNotEmpty;

  /// التحقق من وجود مدير في النظام
  bool get hasOwner {
    return state.users.any(
      (user) => user.role == UserRole.owner && user.isActive,
    );
  }
}
