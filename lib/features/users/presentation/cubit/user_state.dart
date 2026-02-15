import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

final class UserInitial extends UserState {
  const UserInitial();
}

final class UserLoading extends UserState {
  const UserLoading();
}

final class UserLoaded extends UserState {
  final List<UserEntity> users;
  final UserEntity? currentUser;
  final List<UserEntity> filteredUsers;
  final String searchQuery;
  final UserRole? selectedRole;
  final String? selectedDepartment;
  final String? error;
  /// FIX: When true, preserve users/currentUser during load (no flicker).
  final bool isLoading;

  const UserLoaded({
    this.users = const [],
    this.currentUser,
    this.filteredUsers = const [],
    this.searchQuery = '',
    this.selectedRole,
    this.selectedDepartment,
    this.error,
    this.isLoading = false,
  });

  List<UserEntity> get effectiveUsers {
    List<UserEntity> result = filteredUsers.isNotEmpty ? filteredUsers : users;
    if (searchQuery.isEmpty) return result;
    final q = searchQuery.toLowerCase();
    return result
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            (u.department?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  UserLoaded copyWith({
    List<UserEntity>? users,
    UserEntity? currentUser,
    List<UserEntity>? filteredUsers,
    String? searchQuery,
    UserRole? selectedRole,
    String? selectedDepartment,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        users,
        currentUser,
        filteredUsers,
        searchQuery,
        selectedRole,
        selectedDepartment,
        error,
        isLoading,
      ];
}

final class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
