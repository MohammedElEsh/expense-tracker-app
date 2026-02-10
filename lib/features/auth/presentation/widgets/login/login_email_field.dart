// Login - Email Field Widget
import 'package:flutter/material.dart';

class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;

  const LoginEmailField({
    super.key,
    required this.controller,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isRTL ? 'أدخل البريد الإلكتروني' : 'Enter email';
        }
        if (!value.contains('@')) {
          return isRTL ? 'أدخل بريد إلكتروني صحيح' : 'Enter a valid email';
        }
        return null;
      },
    );
  }
}
