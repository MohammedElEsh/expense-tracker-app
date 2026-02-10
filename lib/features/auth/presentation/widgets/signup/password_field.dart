// Signup - Password Field Widget
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isRTL;
  final String? label;
  final bool isConfirmPassword;
  final TextEditingController? passwordToMatch;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isRTL,
    this.label,
    this.isConfirmPassword = false,
    this.passwordToMatch,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText:
            widget.label ??
            (widget.isConfirmPassword
                ? (widget.isRTL ? 'تأكيد كلمة المرور' : 'Confirm Password')
                : (widget.isRTL ? 'كلمة المرور' : 'Password')),
        prefixIcon: Icon(
          widget.isConfirmPassword ? Icons.lock_outline : Icons.lock,
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() => _obscureText = !_obscureText);
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.isRTL ? 'أدخل كلمة المرور' : 'Enter password';
        }
        if (value.length < 6) {
          return widget.isRTL
              ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
              : 'Password must be at least 6 characters';
        }
        if (widget.isConfirmPassword && widget.passwordToMatch != null) {
          if (value != widget.passwordToMatch!.text) {
            return widget.isRTL
                ? 'كلمتا المرور غير متطابقتين'
                : 'Passwords do not match';
          }
        }
        return null;
      },
    );
  }
}
