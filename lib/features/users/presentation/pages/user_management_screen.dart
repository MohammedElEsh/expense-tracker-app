// ✅ User Management Screen - Full Implementation with API Integration
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/core/services/permission_service.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/users/presentation/pages/add_user_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/edit_user_screen.dart';

import 'package:expense_tracker/features/users/presentation/widgets/user_empty_state.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_card.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_access_denied.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_error_state.dart';
import 'package:expense_tracker/features/users/presentation/widgets/delete_user_dialog.dart';

/// User Management Screen - Business mode only
/// Shows all company users with role-based permissions
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _usersList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await serviceLocator.userApiService.getAllUsers();
      if (mounted) {
        setState(() {
          _usersList = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading users: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e is UnauthorizedException) {
            _error = 'Unauthorized: You do not have permission to view users';
          } else if (e is ForbiddenException) {
            _error = 'Forbidden: Access denied';
          } else if (e is NetworkException) {
            _error = 'Network error: Please check your internet connection';
          } else {
            _error = 'Failed to load users: ${e.toString()}';
          }
        });
      }
    }
  }

  Future<void> _handleDeleteUser(String userId, String userName) async {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final currentUser = context.read<UserCubit>().state.currentUser;

    if (currentUser == null || !PermissionService.canManageUsers(currentUser)) {
      _showPermissionError();
      return;
    }

    // Don't allow deleting yourself
    if (currentUser.id == userId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL
                  ? 'لا يمكنك حذف حسابك الخاص'
                  : 'You cannot delete your own account',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await DeleteUserDialog.show(
      context,
      userName: userName,
      isRTL: isRTL,
    );

    if (confirmed && mounted) {
      try {
        await serviceLocator.userApiService.deleteUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL ? 'تم حذف المستخدم بنجاح' : 'User deleted successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        debugPrint('❌ Error deleting user: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL
                    ? 'فشل حذف المستخدم: ${e.toString()}'
                    : 'Failed to delete user: ${e.toString()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleEditUser(Map<String, dynamic> user) async {
    final currentUser = context.read<UserCubit>().state.currentUser;
    if (currentUser == null || !PermissionService.canManageUsers(currentUser)) {
      _showPermissionError();
      return;
    }

    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => EditUserScreen(user: user)));

    if (result == true) {
      _loadUsers();
    }
  }

  void _handleAddUser() async {
    final currentUser = context.read<UserCubit>().state.currentUser;
    if (currentUser == null || !PermissionService.canManageUsers(currentUser)) {
      _showPermissionError();
      return;
    }

    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddUserScreen()));

    if (result == true) {
      _loadUsers();
    }
  }

  void _showPermissionError() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'ليس لديك صلاحية للقيام بهذا الإجراء'
              : 'You do not have permission to perform this action',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        final currentUser = userState.currentUser;
        final canManage = PermissionService.canManageUsers(currentUser);
        final canView = PermissionService.canViewUsers(currentUser);

        if (!canView && !canManage) {
          return UserAccessDenied(isRTL: isRTL);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(isRTL ? 'إدارة المستخدمين' : 'User Management'),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (canManage)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUsers,
                  tooltip: isRTL ? 'تحديث' : 'Refresh',
                ),
            ],
          ),
          body: _buildBody(isRTL, theme, canManage),
          floatingActionButton:
              canManage
                  ? FloatingActionButton.extended(
                    onPressed: _handleAddUser,
                    icon: const Icon(Icons.person_add),
                    label: Text(isRTL ? 'إضافة مستخدم' : 'Add User'),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildBody(bool isRTL, ThemeData theme, bool canManage) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return UserErrorState(error: _error!, isRTL: isRTL, onRetry: _loadUsers);
    }

    if (_usersList.isEmpty) {
      return UserEmptyState(isRTL: isRTL, canManage: canManage);
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usersList.length,
        itemBuilder: (context, index) {
          final user = _usersList[index];
          final userId =
              user['_id']?.toString() ?? user['id']?.toString() ?? '';
          final userName = user['name']?.toString() ?? '';

          return KeyedSubtree(
            key: ValueKey(user['_id'] ?? user['id'] ?? index),
            child: UserCard(
              user: user,
              isRTL: isRTL,
              canManage: canManage,
              onEdit: () => _handleEditUser(user),
              onDelete: () => _handleDeleteUser(userId, userName),
            ),
          );
        },
      ),
    );
  }
}
