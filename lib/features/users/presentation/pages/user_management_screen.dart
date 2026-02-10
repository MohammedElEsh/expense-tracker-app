// ✅ User Management Screen - Full Implementation with API Integration
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/services/permission_service.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/users/presentation/pages/add_user_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/edit_user_screen.dart';

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
    final currentUser = context.read<UserBloc>().state.currentUser;

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

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'حذف المستخدم' : 'Delete User'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من حذف "$userName"؟ لا يمكن التراجع عن هذا الإجراء.'
                  : 'Are you sure you want to delete "$userName"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(isRTL ? 'حذف' : 'Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
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
    final currentUser = context.read<UserBloc>().state.currentUser;
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
    final currentUser = context.read<UserBloc>().state.currentUser;
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

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final currentUser = userState.currentUser;
        final canManage = PermissionService.canManageUsers(currentUser);
        final canView = PermissionService.canViewUsers(currentUser);

        // Check if user has access
        if (!canView && !canManage) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isRTL ? 'إدارة المستخدمين' : 'User Management'),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isRTL
                        ? 'ليس لديك صلاحية للوصول إلى هذه الصفحة'
                        : 'You do not have permission to access this page',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
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
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadUsers,
                          icon: const Icon(Icons.refresh),
                          label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
                        ),
                      ],
                    ),
                  )
                  : _usersList.isEmpty
                  ? _buildEmptyState(context, isRTL, theme, canManage)
                  : _buildUsersList(context, isRTL, theme, canManage),
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

  Widget _buildEmptyState(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
    bool canManage,
  ) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isRTL ? 'لا يوجد مستخدمين' : 'No users found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (canManage)
                Text(
                  isRTL
                      ? 'اضغط على زر + لإضافة مستخدم جديد'
                      : 'Press + button to add a new user',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersList(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
    bool canManage,
  ) {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usersList.length,
        itemBuilder: (context, index) {
          final user = _usersList[index];
          return KeyedSubtree(
            key: ValueKey(user['_id'] ?? user['id'] ?? index),
            child: _buildUserCard(context, user, isRTL, theme, canManage),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Map<String, dynamic> user,
    bool isRTL,
    ThemeData theme,
    bool canManage,
  ) {
    final userId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
    final userName = user['name']?.toString() ?? '';
    final userEmail = user['email']?.toString() ?? '';
    final roleString = user['role']?.toString() ?? 'employee';
    final isActive = user['isActive'] ?? true;

    final role = UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => UserRole.employee,
    );

    final isOwner = role == UserRole.owner;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isActive
                ? (isOwner
                    ? role.color.withOpacity(0.05)
                    : Theme.of(context).cardColor)
                : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border:
            isOwner
                ? Border.all(color: role.color.withOpacity(0.5), width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isOwner ? 0.15 : 0.08),
            blurRadius: isOwner ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (canManage && !isOwner) ? () => _handleEditUser(user) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: role.color.withOpacity(isActive ? 0.2 : 0.1),
                  child: Icon(
                    role.icon,
                    color: isActive ? role.color : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isActive ? null : Colors.grey,
                                decoration:
                                    isActive
                                        ? null
                                        : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          // Owner badge
                          if (isOwner)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: role.color,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: role.color.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRTL ? 'مدير عام' : 'Owner',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isRTL ? 'معطل' : 'Inactive',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isActive ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: role.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.getDisplayName(isRTL),
                          style: TextStyle(
                            color: role.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions - Hide for Owner
                if (canManage && !isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _handleEditUser(user);
                      } else if (value == 'delete') {
                        _handleDeleteUser(userId, userName);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(isRTL ? 'تعديل' : 'Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isRTL ? 'حذف' : 'Delete',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
