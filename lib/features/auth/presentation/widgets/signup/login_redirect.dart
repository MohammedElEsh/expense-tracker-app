// Signup - Login Redirect Widget
import 'package:flutter/material.dart';

class LoginRedirect extends StatelessWidget {
  final bool isRTL;
  final VoidCallback onLoginPressed;

  const LoginRedirect({
    super.key,
    required this.isRTL,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isRTL ? 'لديك حساب بالفعل؟' : 'Already have an account?',
          style: const TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: onLoginPressed,
          child: Text(
            isRTL ? 'تسجيل الدخول' : 'Login',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
