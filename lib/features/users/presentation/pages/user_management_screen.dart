// ✅ User Management Screen - Uses UserCubit only (no service/API access).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_empty_state.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_card.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_access_denied.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_error_state.dart';
import 'package:expense_tracker/features/users/presentation/widgets/delete_user_dialog.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUsers();
  }

  Future<void> _handleDeleteUser(BuildContext context, UserEntity user) async {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final cubit = context.read<UserCubit>();
    if (!cubit.canManageUsers) {
      _showPermissionError(context, isRTL);
      return;
    }
    final currentUser = cubit.state is UserLoaded ? (cubit.state as UserLoaded).currentUser : null;
    if (currentUser != null && currentUser.id == user.id) {
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
      userName: user.name,
      isRTL: isRTL,
    );
    if (confirmed && mounted) {
      try {
        await context.read<UserCubit>().deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL ? 'تم حذف المستخدم بنجاح' : 'User deleted successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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

  void _handleEditUser(BuildContext context, UserEntity user) async {
    if (!context.read<UserCubit>().canManageUsers) {
      _showPermissionError(context, Directionality.of(context) == TextDirection.rtl);
      return;
    }
    final result = await context.push<bool>(
      AppRoutes.editUser,
      extra: user,
    );
    if (result == true && mounted) {
      context.read<UserCubit>().loadUsers();
    }
  }

  void _handleAddUser(BuildContext context) async {
    if (!context.read<UserCubit>().canManageUsers) {
      _showPermissionError(context, Directionality.of(context) == TextDirection.rtl);
      return;
    }
    final result = await context.push<bool>(
      AppRoutes.addUser,
    );
    if (result == true && mounted) {
      context.read<UserCubit>().loadUsers();
    }
  }

  void _showPermissionError(BuildContext context, bool isRTL) {
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
        final cubit = context.read<UserCubit>();
        final canManage = cubit.canManageUsers;
        final canView = cubit.canViewUsers;

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
                  onPressed: () => context.read<UserCubit>().loadUsers(),
                  tooltip: isRTL ? 'تحديث' : 'Refresh',
                ),
            ],
          ),
          body: _buildBody(context, userState, isRTL, canManage),
          floatingActionButton: canManage
              ? FloatingActionButton.extended(
                  onPressed: () => _handleAddUser(context),
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

  Widget _buildBody(
    BuildContext context,
    UserState userState,
    bool isRTL,
    bool canManage,
  ) {
    if (userState is UserLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userState is UserError) {
      return UserErrorState(
        error: userState.message,
        isRTL: isRTL,
        onRetry: () => context.read<UserCubit>().loadUsers(),
      );
    }
    if (userState is UserLoaded) {
      final users = userState.effectiveUsers;
      if (users.isEmpty) {
        return UserEmptyState(isRTL: isRTL, canManage: canManage);
      }
      return RefreshIndicator(
        onRefresh: () => context.read<UserCubit>().loadUsers(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return KeyedSubtree(
              key: ValueKey(user.id),
              child: UserCard(
                user: user,
                isRTL: isRTL,
                canManage: canManage,
                onEdit: () => _handleEditUser(context, user),
                onDelete: () => _handleDeleteUser(context, user),
              ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
