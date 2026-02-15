// Home Feature - Presentation Layer - Logout Confirmation Dialog Widget
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeLogoutDialog extends StatelessWidget {
  final bool isRTL;

  const HomeLogoutDialog({super.key, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
      content: Text(
        isRTL
            ? 'هل أنت متأكد من تسجيل الخروج؟'
            : 'Are you sure you want to logout?',
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(isRTL ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () => context.pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, {required bool isRTL}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => HomeLogoutDialog(isRTL: isRTL),
    );
  }
}
