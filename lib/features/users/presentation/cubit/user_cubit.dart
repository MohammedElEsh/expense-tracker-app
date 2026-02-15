import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/features/users/domain/usecases/create_user_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/delete_user_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/get_users_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/update_user_usecase.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUsersUseCase getUsersUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  UserCubit({
    required this.getUsersUseCase,
    required this.createUserUseCase,
    required this.updateUserUseCase,
    required this.deleteUserUseCase,
  }) : super(const UserInitial());

  Future<void> loadUsers() async {
    // FIX: Preserve users/currentUser during load to prevent UI flicker.
    final prev = state is UserLoaded ? state as UserLoaded : null;
    if (prev != null) {
      emit(prev.copyWith(isLoading: true));
    } else {
      emit(const UserLoading());
    }
    try {
      final users = await getUsersUseCase();
      emit(UserLoaded(
        users: users,
        currentUser: prev?.currentUser,
        filteredUsers: const [],
        error: null,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('❌ UserCubit loadUsers: $e');
      if (prev != null) {
        emit(prev.copyWith(isLoading: false, error: e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
    }
  }

  Future<void> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final entity = UserEntity(
      id: '',
      name: name,
      email: email,
      role: role,
    );
    try {
      await createUserUseCase(entity, password: password);
      await loadUsers();
    } catch (e) {
      if (state is UserLoaded) {
        emit((state as UserLoaded).copyWith(error: e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
      rethrow;
    }
  }

  Future<void> updateUserFromApi({
    required String userId,
    String? name,
    UserRole? role,
  }) async {
    final current = state is UserLoaded ? (state as UserLoaded).users : <UserEntity>[];
    UserEntity? existing;
    for (final u in current) {
      if (u.id == userId) {
        existing = u;
        break;
      }
    }
    if (existing == null) {
      final loaded = await getUsersUseCase();
      UserEntity? found;
      for (final u in loaded) {
        if (u.id == userId) {
          found = u;
          break;
        }
      }
      if (found == null) throw StateError('User not found');
      await _emitUpdateUser(found, name: name, role: role);
      return;
    }
    await _emitUpdateUser(existing, name: name, role: role);
  }

  Future<void> _emitUpdateUser(UserEntity existing, {String? name, UserRole? role}) async {
    final entity = existing.copyWith(
      name: name ?? existing.name,
      role: role ?? existing.role,
    );
    try {
      await updateUserUseCase(entity);
      await loadUsers();
    } catch (e) {
      if (state is UserLoaded) {
        emit((state as UserLoaded).copyWith(error: e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await deleteUserUseCase(userId);
      if (state is UserLoaded) {
        final s = state as UserLoaded;
        final updated = s.users.where((u) => u.id != userId).toList();
        final updatedCurrent = s.currentUser?.id == userId ? null : s.currentUser;
        emit(s.copyWith(users: updated, currentUser: updatedCurrent));
      }
    } catch (e) {
      if (state is UserLoaded) {
        emit((state as UserLoaded).copyWith(error: e.toString()));
      } else {
        emit(UserError(e.toString()));
      }
      rethrow;
    }
  }

  void setCurrentUser(UserEntity? user) {
    if (state is UserLoaded) {
      emit((state as UserLoaded).copyWith(currentUser: user));
    } else {
      emit(UserLoaded(users: [], currentUser: user));
    }
  }

  void searchUsers(String query) {
    if (state is UserLoaded) {
      emit((state as UserLoaded).copyWith(searchQuery: query));
    }
  }

  void filterUsersByRole(UserRole? role) {
    if (state is! UserLoaded) return;
    final s = state as UserLoaded;
    final filtered = role == null ? s.users : s.users.where((u) => u.role == role).toList();
    emit(s.copyWith(selectedRole: role, filteredUsers: filtered));
  }

  void filterUsersByDepartment(String? department) {
    if (state is! UserLoaded) return;
    final s = state as UserLoaded;
    final filtered = department == null
        ? s.users
        : s.users.where((u) => u.department == department).toList();
    emit(s.copyWith(selectedDepartment: department, filteredUsers: filtered));
  }

  void clearUserFilters() {
    if (state is UserLoaded) {
      emit((state as UserLoaded).copyWith(
        searchQuery: '',
        selectedRole: null,
        selectedDepartment: null,
        filteredUsers: [],
      ));
    }
  }

  bool get hasUsers => state is UserLoaded && (state as UserLoaded).users.isNotEmpty;
  bool get hasOwner =>
      state is UserLoaded &&
      (state as UserLoaded).users.any((u) => u.role == UserRole.owner && u.isActive);

  /// Whether current user can manage users (owner only). No static service; logic in Cubit.
  bool get canManageUsers {
    if (state is! UserLoaded) return false;
    final user = (state as UserLoaded).currentUser;
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner;
  }

  /// Whether current user can view user list (owner or accountant). No static service.
  bool get canViewUsers {
    if (state is! UserLoaded) return false;
    final user = (state as UserLoaded).currentUser;
    if (user == null || !user.isActive) return false;
    return user.role == UserRole.owner || user.role == UserRole.accountant;
  }
}
