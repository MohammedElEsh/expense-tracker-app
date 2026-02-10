import 'package:flutter/material.dart';

class UserAccessDenied extends StatelessWidget {
  const UserAccessDenied({super.key, required this.isRTL});

  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}
