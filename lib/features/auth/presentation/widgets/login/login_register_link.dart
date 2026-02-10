// Login - Register Link Widget
import 'package:flutter/material.dart';

class LoginRegisterLink extends StatelessWidget {
  final bool isRTL;
  final VoidCallback onPressed;

  const LoginRegisterLink({
    super.key,
    required this.isRTL,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      child: Text(
        isRTL
            ? 'ليس لديك حساب؟ أنشئ حساب جديد'
            : "Don't have an account? Create one",
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
