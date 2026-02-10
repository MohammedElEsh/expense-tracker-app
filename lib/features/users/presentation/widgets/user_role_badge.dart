import 'package:flutter/material.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

class UserRoleBadge extends StatelessWidget {
  const UserRoleBadge({
    super.key,
    required this.role,
    required this.isRTL,
    required this.isActive,
    required this.isOwner,
  });

  final UserRole role;
  final bool isRTL;
  final bool isActive;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      return _buildOwnerBadge();
    }

    if (!isActive) {
      return _buildInactiveBadge();
    }

    return const SizedBox.shrink();
  }

  Widget _buildOwnerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const Icon(Icons.star, size: 14, color: Colors.white),
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
    );
  }

  Widget _buildInactiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}
