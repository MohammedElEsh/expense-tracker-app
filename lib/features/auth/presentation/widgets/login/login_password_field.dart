// Login - Password Field Widget
import 'package:flutter/material.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.isRTL,
    required this.obscurePassword,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        labelText: isRTL ? 'كلمة المرور' : 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isRTL ? 'أدخل كلمة المرور' : 'Enter password';
        }
        return null;
      },
    );
  }
}
