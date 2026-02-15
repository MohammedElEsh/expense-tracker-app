import 'package:flutter/material.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/features/users/presentation/utils/user_role_display.dart';
import 'package:expense_tracker/features/users/presentation/widgets/user_role_badge.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.isRTL,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final UserEntity user;
  final bool isRTL;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = user.role;
    final isOwner = role == UserRole.owner;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: user.isActive
            ? (isOwner ? role.color.withOpacity(0.05) : Theme.of(context).cardColor)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: isOwner ? Border.all(color: role.color.withOpacity(0.5), width: 2) : null,
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
          onTap: (canManage && !isOwner) ? onEdit : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: role.color.withOpacity(user.isActive ? 0.2 : 0.1),
                  child: Icon(
                    role.icon,
                    color: user.isActive ? role.color : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: user.isActive ? null : Colors.grey,
                                decoration: user.isActive ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          UserRoleBadge(
                            role: role,
                            isRTL: isRTL,
                            isActive: user.isActive,
                            isOwner: isOwner,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: user.isActive ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                if (canManage && !isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
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
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(isRTL ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red)),
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
