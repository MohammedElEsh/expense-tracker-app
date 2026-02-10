// ✅ Clean Architecture - Presentation BLoC
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/users/data/datasources/user_service.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  static const String usersBoxName = 'users';
  static const String _currentUserKey = 'current_user';

  UserBloc() : super(const UserState()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<ToggleUserStatus>(_onToggleUserStatus);
    on<UpdateLastLogin>(_onUpdateLastLogin);
    on<ChangeUserRole>(_onChangeUserRole);
    on<SearchUsers>(_onSearchUsers);
    on<FilterUsersByRole>(_onFilterUsersByRole);
    on<FilterUsersByDepartment>(_onFilterUsersByDepartment);
    on<ClearUserFilters>(_onClearUserFilters);
    on<SetCurrentUser>(_onSetCurrentUser);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
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

  Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
    try {
      await UserService.updateUser(event.user);

      final updatedUsers = List<User>.from(state.users)..add(event.user);

      emit(state.copyWith(users: updatedUsers));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to add user: $error'));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    try {
      // تحديث المستخدم في قاعدة البيانات
      await UserService.updateUser(event.user);

      // تحديث قائمة المستخدمين في الـ state
      final updatedUsers =
          state.users.map((user) {
            return user.id == event.user.id ? event.user : user;
          }).toList();

      // تحديث المستخدم الحالي إذا كان هو المحدث
      final updatedCurrentUser =
          state.currentUser?.id == event.user.id
              ? event.user
              : state.currentUser;

      emit(
        state.copyWith(users: updatedUsers, currentUser: updatedCurrentUser),
      );
    } catch (error) {
      emit(state.copyWith(error: 'Failed to update user: $error'));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    try {
      await UserService.deleteUser(event.userId);

      final updatedUsers =
          state.users.where((user) => user.id != event.userId).toList();

      // إذا كان المستخدم المحذوف هو المستخدم الحالي، قم بتسجيل الخروج
      final updatedCurrentUser =
          state.currentUser?.id == event.userId ? null : state.currentUser;

      emit(
        state.copyWith(users: updatedUsers, currentUser: updatedCurrentUser),
      );
    } catch (error) {
      emit(state.copyWith(error: 'Failed to delete user: $error'));
    }
  }

  Future<void> _onToggleUserStatus(
    ToggleUserStatus event,
    Emitter<UserState> emit,
  ) async {
    try {
      final updatedUser = await UserService.toggleUserStatus(event.userId);
      add(UpdateUser(updatedUser));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to toggle user status: $error'));
    }
  }

  Future<void> _onUpdateLastLogin(
    UpdateLastLogin event,
    Emitter<UserState> emit,
  ) async {
    try {
      final user = state.getUserById(event.userId);
      if (user == null) return;

      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await UserService.updateUser(updatedUser);
      add(UpdateUser(updatedUser));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to update last login: $error'));
    }
  }

  Future<void> _onChangeUserRole(
    ChangeUserRole event,
    Emitter<UserState> emit,
  ) async {
    try {
      final user = state.getUserById(event.userId);
      if (user == null) return;

      // تحديث الدور عبر REST API
      await serviceLocator.authRemoteDataSource.updateUserRole(
        event.userId,
        event.newRole.name,
      );

      final updatedUser = user.copyWith(role: event.newRole);
      await UserService.updateUser(updatedUser);
      add(UpdateUser(updatedUser));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to change user role: $error'));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterUsersByRole(FilterUsersByRole event, Emitter<UserState> emit) {
    List<User> filteredUsers = state.users;

    if (event.role != null) {
      filteredUsers =
          filteredUsers.where((user) => user.role == event.role).toList();
    }

    emit(
      state.copyWith(selectedRole: event.role, filteredUsers: filteredUsers),
    );
  }

  void _onFilterUsersByDepartment(
    FilterUsersByDepartment event,
    Emitter<UserState> emit,
  ) {
    List<User> filteredUsers = state.users;

    if (event.department != null) {
      filteredUsers =
          filteredUsers
              .where((user) => user.department == event.department)
              .toList();
    }

    emit(
      state.copyWith(
        selectedDepartment: event.department,
        filteredUsers: filteredUsers,
      ),
    );
  }

  void _onClearUserFilters(ClearUserFilters event, Emitter<UserState> emit) {
    emit(
      state.copyWith(
        searchQuery: '',
        selectedRole: null,
        selectedDepartment: null,
        filteredUsers: [],
      ),
    );
  }

  Future<void> _onSetCurrentUser(
    SetCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Check if user or role changed
      final previousUser = state.currentUser;
      final newUser = event.user;

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
        add(UpdateLastLogin(newUser.id));
      } else {
        final currentUserBox = await Hive.openBox(_currentUserKey);
        await currentUserBox.delete('id');
      }

      emit(state.copyWith(currentUser: event.user));
    } catch (error) {
      emit(state.copyWith(error: 'Failed to set current user: $error'));
    }
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<UserState> emit) async {
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

    add(AddUser(defaultOwner));
    add(SetCurrentUser(defaultOwner));
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
