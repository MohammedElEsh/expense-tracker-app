import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteUserDialog extends StatelessWidget {
  const DeleteUserDialog({
    super.key,
    required this.userName,
    required this.isRTL,
  });

  final String userName;
  final bool isRTL;

  /// Shows the delete confirmation dialog and returns true if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String userName,
    required bool isRTL,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteUserDialog(userName: userName, isRTL: isRTL),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isRTL ? 'حذف المستخدم' : 'Delete User'),
      content: Text(
        isRTL
            ? 'هل أنت متأكد من حذف "$userName"؟ لا يمكن التراجع عن هذا الإجراء.'
            : 'Are you sure you want to delete "$userName"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(isRTL ? 'إلغاء' : 'Cancel'),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(isRTL ? 'حذف' : 'Delete'),
        ),
      ],
    );
  }
}
